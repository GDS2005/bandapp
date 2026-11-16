-- =====================================================================
-- BandApp v0.4 · Base de datos en Supabase
-- Pegá TODO este archivo en Supabase → SQL Editor → New query → Run.
-- Se puede volver a correr sin problema: no borra datos.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Tablas
--    Cada fila guarda el objeto tal como lo usa la app (columna data),
--    así los campos nuevos (capo, fContent, origFilter…) no piden cambios en la base.
-- ---------------------------------------------------------------------

-- Canciones: una fila por canción y por persona
create table if not exists public.songs (
  owner_id   uuid        not null default auth.uid() references auth.users(id) on delete cascade,
  id         text        not null check (id ~ '^[A-Za-z0-9_-]{1,80}$'),
  data       jsonb       not null check (jsonb_typeof(data) = 'object' and octet_length(data::text) < 300000),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (owner_id, id)
);

-- Listas: share_id es el código del link de solo lectura (imposible de adivinar)
create table if not exists public.lists (
  owner_id   uuid        not null default auth.uid() references auth.users(id) on delete cascade,
  id         text        not null check (id ~ '^[A-Za-z0-9_-]{1,80}$'),
  data       jsonb       not null check (jsonb_typeof(data) = 'object' and octet_length(data::text) < 200000),
  share_id   uuid        not null default gen_random_uuid() unique,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (owner_id, id)
);

-- Progreso del modo Aprender: una fila por persona
create table if not exists public.progress (
  owner_id   uuid        primary key default auth.uid() references auth.users(id) on delete cascade,
  data       jsonb       not null default '{}'::jsonb check (jsonb_typeof(data) = 'object' and octet_length(data::text) < 100000),
  updated_at timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- 2. Permisos (Row Level Security): cada persona ve y cambia SOLO lo suyo
-- ---------------------------------------------------------------------
alter table public.songs    enable row level security;
alter table public.lists    enable row level security;
alter table public.progress enable row level security;

drop policy if exists "songs: solo el dueño"    on public.songs;
drop policy if exists "lists: solo el dueño"    on public.lists;
drop policy if exists "progress: solo el dueño" on public.progress;

create policy "songs: solo el dueño" on public.songs
  for all to authenticated
  using (owner_id = (select auth.uid()))
  with check (owner_id = (select auth.uid()));

create policy "lists: solo el dueño" on public.lists
  for all to authenticated
  using (owner_id = (select auth.uid()))
  with check (owner_id = (select auth.uid()));

create policy "progress: solo el dueño" on public.progress
  for all to authenticated
  using (owner_id = (select auth.uid()))
  with check (owner_id = (select auth.uid()));

-- Quien no inició sesión no puede tocar las tablas directamente
revoke all on public.songs, public.lists, public.progress from anon;
grant select, insert, update, delete on public.songs, public.lists, public.progress to authenticated;

-- ---------------------------------------------------------------------
-- 3. Lista compartida (link de solo lectura)
--    Devuelve la lista y SOLO sus canciones, aunque quien abre el link no tenga cuenta.
--    Una lista "que se actualiza sola" aplica su filtro acá, igual que la app.
-- ---------------------------------------------------------------------
create or replace function public.get_shared_list(p_share_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  l        public.lists%rowtype;
  f        jsonb;
  q        text;
  fstatus  text;
  flevel   text;
  ftag     text;
  fcontent text;
  result   jsonb;
begin
  select * into l from public.lists where share_id = p_share_id;
  if not found then
    return null;
  end if;

  if coalesce((l.data->>'live')::boolean, false) and jsonb_typeof(l.data->'filter') = 'object' then
    f        := l.data->'filter';
    q        := lower(btrim(coalesce(f->>'q', '')));
    fstatus  := nullif(f->>'fStatus', '');
    flevel   := nullif(f->>'fLevel', '');
    ftag     := nullif(f->>'fTag', '');
    fcontent := coalesce(nullif(f->>'fContent', ''), case when ftag = '__link' then 'link' end);

    select coalesce(jsonb_agg(s.data || jsonb_build_object('id', s.id)), '[]'::jsonb)
      into result
      from public.songs s
     where s.owner_id = l.owner_id
       and (q = '' or position(q in lower(
             coalesce(s.data->>'title', '') || ' ' || coalesce(s.data->>'artist', '') || ' ' ||
             coalesce((select string_agg(t, ' ')
                         from jsonb_array_elements_text(
                                case when jsonb_typeof(s.data->'tags') = 'array' then s.data->'tags' else '[]'::jsonb end) t), '')
           )) > 0)
       and (fstatus is null or
            (case when s.data->>'status' in ('aprender', 'practicando', 'lase') then s.data->>'status' else 'aprender' end) = fstatus)
       and (flevel is null or s.data->>'level' = flevel)
       and (fcontent is null
            or (fcontent = 'link'   and regexp_replace(coalesce(s.data->>'body', ''), '\s', '', 'g') = '')
            or (fcontent = 'lyrics' and regexp_replace(coalesce(s.data->>'body', ''), '\s', '', 'g') <> ''))
       and (ftag is null or ftag = '__link' or
            (jsonb_typeof(s.data->'tags') = 'array' and s.data->'tags' ? ftag));
  else
    select coalesce(jsonb_agg(s.data || jsonb_build_object('id', s.id)), '[]'::jsonb)
      into result
      from public.songs s
     where s.owner_id = l.owner_id
       and jsonb_typeof(l.data->'songIds') = 'array'
       and s.id in (select jsonb_array_elements_text(l.data->'songIds'));
  end if;

  return jsonb_build_object(
    'list',  l.data || jsonb_build_object('id', l.id, 'shareId', l.share_id),
    'songs', result
  );
end;
$$;

revoke all on function public.get_shared_list(uuid) from public;
grant execute on function public.get_shared_list(uuid) to anon, authenticated;

-- ---------------------------------------------------------------------
-- 4. Cambios en vivo entre la compu y el teléfono (Realtime)
-- ---------------------------------------------------------------------
do $$
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    begin alter publication supabase_realtime add table public.songs;    exception when duplicate_object then null; end;
    begin alter publication supabase_realtime add table public.lists;    exception when duplicate_object then null; end;
    begin alter publication supabase_realtime add table public.progress; exception when duplicate_object then null; end;
  end if;
end $$;

-- Listo. Si ves "Success. No rows returned", la base quedó creada.
