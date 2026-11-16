# BandApp v0.5 — Cómo publicarla (Netlify + Supabase)

Esta guía es para hacerlo **sin saber programar**. Lleva entre 1 y 2 horas, una sola vez. Al final vas a tener:

- tu dirección propia (por ejemplo `bandapp-camila.netlify.app`),
- entrada con **email y contraseña**; las cuentas las creás vos para quien quieras,
- tu cancionero sincronizado entre la compu y el teléfono,
- listas que se abren **en solo lectura** con un link o un **QR**, sin cuenta,
- un botón para que tus amigos con cuenta **guarden en su cancionero** las canciones de una lista.

Todo en planes gratuitos, y **sin configurar ningún servicio de mails**.

---

## Qué hay en esta carpeta

| Archivo | Para qué es | ¿Lo tocás? |
|---|---|---|
| `index.html` | La app completa | No |
| `config.js` | Los datos de conexión con tu base | **Sí, una vez** (paso 3) |
| `supabase.sql` | Crea las tablas y los permisos | Lo pegás en Supabase (paso 2) |
| `manifest.webmanifest`, `icon-192.png`, `icon-512.png`, `apple-touch-icon.png` | Ícono y nombre cuando la agregás a la pantalla del teléfono | No |
| `README.md` | Esta guía | No |
| `RELEASE_NOTES_v0.5.md` | Qué cambió en esta versión | No |

---

## Paso 0. Hacé una copia de tus canciones (5 min)

1. Abrí BandApp en Claude.
2. Entrá a **☰ → Importar y exportar → Descargar una copia → Copia completa (JSON)**.
3. Guardá el archivo (por ejemplo `bandapp-backup-2026-11-16.json`) en tu compu y en Drive.

Ese archivo es el que vas a cargar en la versión nueva (paso 7).

## Paso 1. Crear el proyecto en Supabase (≈5 min)

1. Entrá a **supabase.com** → **Start your project** y registrate con **email y contraseña**. Después activá la verificación en dos pasos en la configuración de tu cuenta (sección *Security*).
2. Tocá **New project**:
   - **Name:** `bandapp`
   - **Database Password:** tocá *Generate a password* y guardala en un lugar seguro.
   - **Region:** *South America (São Paulo)*.
3. Tocá **Create new project** y esperá 1 o 2 minutos.

## Paso 2. Crear las tablas (≈3 min)

1. En el menú de la izquierda, entrá a **SQL Editor** → **New query**.
2. Abrí `supabase.sql` con el Bloc de notas (o TextEdit), copiá todo y pegalo en el editor.
3. Tocá **Run**. Tiene que decir **Success. No rows returned**.

> El archivo no borra nada y se puede volver a correr sin problema.

## Paso 3. Conectar la app con tu base (≈5 min)

1. En Supabase, abrí **Project Settings** (el engranaje) → **API** (en algunas cuentas aparece como **Data API** y **API Keys**).
2. Copiá dos datos:
   - **Project URL**, algo como `https://abcdxyz.supabase.co`
   - **anon public key** (en cuentas nuevas, **publishable key**), un texto largo.
3. Abrí `config.js` con el Bloc de notas y reemplazá lo que está entre comillas:

   ```js
   window.BANDAPP_CONFIG = {
     SUPABASE_URL: 'https://abcdxyz.supabase.co',
     SUPABASE_ANON_KEY: 'eyJhbGciOi...el texto largo...'
   };
   ```

4. Guardá el archivo.

> La *anon key* puede ir en un archivo público: está pensada para eso, y las reglas de la base hacen que cada persona vea solo lo suyo. La que **nunca** se pega en ningún lado es la **service_role** (o *secret key*).

## Paso 4. Cuentas: cerrar el registro y crear la tuya (≈5 min)

Así nadie puede crearse una cuenta por su cuenta: las creás vos.

1. **Cerrar el registro:** **Authentication → Sign In / Providers**. En **User Signups**, apagá **Allow new users to sign up** y tocá **Save**. Dejá encendido el proveedor **Email**.
2. **Crear tu cuenta:** **Authentication → Users → Add user → Create new user**.
   - Poné tu email y una contraseña de al menos 8 caracteres.
   - Marcá **Auto Confirm User**.
   - Tocá **Create user**.

> Como sos dueña del proyecto, también podés entrar con **"Entrar con un código por mail"**: el servicio de mails de fábrica de Supabase te manda el código a vos.

## Paso 5. Publicar en Netlify, sin GitHub (≈10 min)

Publicar arrastrando la carpeta es lo más simple y evita depender de una cuenta de GitHub.

1. Entrá a **netlify.com** → **Sign up** y registrate **con email y contraseña** (no con "Sign up with GitHub"). Después activá la verificación en dos pasos en la configuración de tu cuenta (sección *Security*).
2. Tocá **Add new site** (o *Add new project*) → **Deploy manually**.
3. Arrastrá la carpeta `bandapp-v0.5` completa, con `config.js` ya completo.
4. En un minuto te da una dirección como `algo-raro-123.netlify.app`. Para cambiarla: **Site configuration** (o *Project configuration*) → **Change site name** → `bandapp-camila` (o el que esté libre).

**Volvé a Supabase con la dirección:**

1. Entrá a **Authentication → URL Configuration**.
2. En **Site URL**, pegá tu dirección completa, por ejemplo `https://bandapp-camila.netlify.app`.
3. En **Redirect URLs** → **Add URL**, pegá la misma dirección y tocá **Save**.

> ¿Preferís usar GitHub para tener historial? Funciona igual: repositorio **privado**, verificación en dos pasos y sin GitHub Actions. Después, en Netlify, **Import an existing project → GitHub**.

## Paso 6. Opcional: que el mail traiga un código

Solo hace falta si vas a usar **"Entrar con un código por mail"**. Sin este paso, el mail trae solo un link.

1. Entrá a **Authentication → Emails** (o **Email Templates**) → plantilla **Magic Link**.
2. En *Message body*, pegá esto:

   ```html
   <h2>Tu código para entrar a BandApp</h2>
   <p style="font-size:28px;letter-spacing:6px"><b>{{ .Token }}</b></p>
   <p>O tocá este link desde el mismo dispositivo: <a href="{{ .ConfirmationURL }}">entrar a BandApp</a></p>
   ```

3. En **Subject** poné `Tu código de BandApp` y tocá **Save**.

## Paso 7. Entrar y cargar tus canciones (≈5 min)

1. Abrí tu dirección de Netlify y entrá con tu email y contraseña.
2. Entrá a **☰ → Importar y exportar → Importar archivos de canciones → Elegir archivos**, elegí el backup JSON del paso 0 y tocá **Importar**.
3. Revisá que estén las canciones, las listas, el capo de cada una y tu progreso de Aprender.

> Las listas importadas tienen links **nuevos**. Los links viejos de Claude no apuntan a esta versión.

## Paso 8. Usarla en el teléfono

1. Abrí la dirección en el teléfono y entrá con tu cuenta.
2. Agregala a la pantalla de inicio:
   - **Android (Chrome):** menú ⋮ → **Agregar a la pantalla principal** (o *Instalar app*).
   - **iPhone (Safari):** botón Compartir → **Agregar a inicio**.
3. Queda un ícono con la clave de sol que abre BandApp a pantalla completa.

> En iPhone, la app del ícono tiene su propia sesión: la primera vez te pide entrar de nuevo. Es normal.

---

## Dar de alta a un amigo

1. En Supabase: **Authentication → Users → Add user → Create new user**. Poné su email y una contraseña provisoria, marcá **Auto Confirm User** y tocá **Create user**.
2. Pasale la dirección de BandApp y la contraseña, mejor por mensaje privado.
3. Pedile que, al entrar, la cambie en **☰ → Cambiar contraseña**.

Tu amigo tiene su propio cancionero, separado del tuyo: no ve tus canciones y vos no ves las suyas.

**Si se olvida la contraseña:** en Supabase, **SQL Editor → New query**, pegá esto (con su email y una contraseña nueva) y tocá **Run**:

```sql
update auth.users
set encrypted_password = extensions.crypt('NuevaClave2026', extensions.gen_salt('bf'))
where email = 'amigo@ejemplo.com';
```

Pasale la nueva y que la cambie desde el menú.

**Para dar de baja a alguien:** **Authentication → Users** → los tres puntos de esa persona → **Delete user**. Se borran también sus canciones y listas.

## Compartir y la jam

- **Link de una lista:** abrila → **Ver más → Copiar link** o **WhatsApp**. Quien lo abre la ve en **solo lectura**, sin cuenta: puede abrir las canciones, transponer, poner capo y usar el autoscroll, pero no editar nada.
- **QR:** en la lista, tocá **QR** y mostrá la pantalla para que lo escaneen con la cámara. Cualquiera que tenga la lista abierta puede mostrar el QR, así los demás también la pasan.
- **Guardar canciones de una lista:** quien tenga cuenta y abra el link ve **"Guardar en mi cancionero"** (una canción) o **"Guardar las N en mi cancionero"** (todas). Si no había entrado, la app le pide entrar y lo devuelve a la lista. Se copian letra, acordes, tono, capo, nivel, etiquetas y link; el estado arranca en "Por aprender". Las que ya tiene no se duplican.
- **Lista para la jam:** etiquetá las canciones (por ejemplo `jam`), filtrá por esa etiqueta y compartila con **"Que se actualice sola"**. Lo que etiquetes después entra solo; quien ya la tiene abierta lo ve al recargar.
- **Para cortar el acceso:** borrá la lista. Las canciones no se borran; el link y el QR dejan de funcionar.

**Antes de la jam:** abrí la app un rato antes. En el plan gratis, Supabase pausa la base tras 7 días sin uso.

## Si algo no funciona

| Qué ves | Qué hacer |
|---|---|
| Arriba dice **"Modo local"** | `config.js` no está completo o tiene un error. Revisá el paso 3 (que las comillas sigan estando) y volvé a arrastrar la carpeta a Netlify. |
| **"Email o contraseña incorrectos"** | Revisá mayúsculas. Si la persona no recuerda la contraseña, poné una nueva con el SQL de "Si se olvida la contraseña". |
| **"Tu cuenta todavía no está confirmada"** | En **Authentication → Users**, esa cuenta no tiene *Auto Confirm*. Borrala y creala de nuevo marcando **Auto Confirm User**. |
| **"No hay una cuenta con ese email"** al pedir código | El código por mail solo sirve para cuentas que ya existen. Creala en el paso 4 o en "Dar de alta a un amigo". |
| El QR dice que no se pudo generar | Hace falta conexión a internet para dibujarlo. Mientras tanto, usá **Copiar link**. |
| **"No pude cargar tu cancionero"** después de días sin usarla | Entrá a supabase.com, abrí el proyecto y tocá **Restore project**. Tus datos no se pierden. |

## Cómo actualizar después (v0.5 → v0.6…)

1. Pedís los cambios en un chat del proyecto BandApp en Claude.
2. Claude te devuelve los archivos nuevos y las notas de versión (Nuevo / Cambios / Arreglos / Base de datos / Cómo actualizar).
3. Si las notas dicen **"Base de datos: sí"**, primero corré en Supabase (**SQL Editor**) el SQL indicado.
4. En Netlify, abrí tu sitio → pestaña **Deploys** → arrastrá la carpeta nueva, **con tu `config.js` completo adentro**.
5. En un minuto está publicada. Tus datos no se tocan: viven en Supabase.

## Seguridad, en corto

- Verificación en dos pasos en Supabase y Netlify (y en GitHub, si lo usás). Contraseñas únicas.
- La única clave que va en la app es la pública (`anon`). La `service_role` no se copia nunca.
- Cada cuenta solo puede leer y cambiar sus propias canciones. Las listas compartidas se abren con un código imposible de adivinar, y solo muestran esa lista.
- Sin GitHub en el medio, una cuenta de GitHub comprometida no puede cambiar tu app.

## Cómo funciona por dentro (para quien quiera saberlo)

- **Tablas:** `songs`, `lists` y `progress`. Cada fila tiene el dueño (`owner_id`) y el contenido tal cual lo usa la app (`data`).
- **Permisos:** reglas de Supabase (Row Level Security): cada persona solo puede leer y cambiar sus propias filas.
- **Links de solo lectura:** cada lista tiene un `share_id`. El link `…/#ver-<código>` llama a la función `get_shared_list`, que devuelve esa lista y sus canciones, y nada más.
- **Guardar desde una lista:** copia cada canción al cancionero de quien la guarda; si ya existía, la saltea.
- **Cuentas:** entrada con email y contraseña (`signInWithPassword`); el código por mail no crea cuentas nuevas.
