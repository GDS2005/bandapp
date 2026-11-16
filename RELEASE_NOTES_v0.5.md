## v0.5 — 2026-11-16 · cuentas con contraseña, guardar desde listas, QR y letra que entra en la pantalla

**Resumen:** versión pensada para la jam. Las cuentas ahora tienen email y contraseña y las crea quien administra BandApp, así que no hace falta ningún servicio de mails. Quien abre una lista compartida puede mostrar un QR para pasarla, y si tiene cuenta, guardar las canciones en su cancionero. En el teléfono, los renglones largos se adaptan al ancho de la pantalla y ya no hace falta deslizar de costado.

### Nuevo
- **Entrar con email y contraseña.** Es la forma principal de entrar. Las cuentas se crean a mano desde el panel de Supabase (Authentication → Users → Add user), sin registro abierto ni servicio de mails.
- **Cambiar contraseña** desde ☰ → Cambiar contraseña (mínimo 8 caracteres). Pensado para que cada amigo cambie la contraseña provisoria que le pasaste.
- **Guardar en mi cancionero** desde una lista compartida:
  - En cada canción: "＋ Guardar en mi cancionero".
  - En la lista: "＋ Guardar las N en mi cancionero".
  - Se copian letra, acordes, tono, capo, nivel, etiquetas y link. El estado arranca en "Por aprender".
  - Las que ya tenés no se duplican y el botón pasa a "✓ Ya está(n) en tu cancionero".
  - Si no habías entrado, la app te lleva a entrar y te devuelve a la misma lista.
- **QR de la lista:**
  - Botón "QR" arriba de la lista y "Mostrar QR" en Ver más.
  - Muestra un código grande para escanear con la cámara y abrir la lista sin cuenta.
  - Lo puede mostrar también quien abrió la lista con el link, para pasarla en el momento a otros músicos.
- **El link de la lista se ve también desde una lista compartida** (Copiar link, WhatsApp y QR), no solo desde la cuenta de quien la creó.
- En una lista compartida, el menú ☰ ofrece **"Entrar con mi cuenta"**, o **"Ir a mi cancionero"** si ya entraste.

### Cambios
- **Renglones largos en el teléfono, sin scroll lateral.** En las canciones con acordes arriba de la letra, un renglón que no entra en la pantalla se corta en tramos:
  - Cada acorde queda arriba de su sílaba; nunca se corta en medio de un acorde ni de una palabra.
  - Los tramos que siguen van con una sangría corta, para distinguirlos de un renglón nuevo.
  - Se recalcula solo al girar el teléfono, cambiar el tamaño de letra, transponer o cambiar el capo.
  - Las líneas solo de acordes (por ejemplo, un Intro largo) y los renglones de letra sin acordes también se acomodan al ancho.
  - La vista previa del editor usa el mismo ajuste.
- **Autoscroll en velocidad 1 por defecto** (antes 4). Se puede subir desde el panel de controles como siempre.
- **Nueva canción:** "Escribir letra y acordes" pasa a ser la primera opción, con su botón destacado, para no tener que hacer scroll. Le siguen "Desde un enlace", "Muchos enlaces de una vez" e "Importar en cantidad".
- **"Entrar con un código por mail"** queda como alternativa en la pantalla de entrada. Ya no crea cuentas nuevas: solo sirve para cuentas existentes.
- **En una lista compartida**, el botón "Crear mi cancionero" pasa a ser "Entrar" (no hay registro abierto).
- **Pantalla de entrada:** aclara qué hacer si no tenés cuenta o te olvidaste la contraseña.
- **Guía:** la publicación recomendada pasa a ser en Netlify arrastrando la carpeta, sin GitHub. GitHub queda como opción, con recomendaciones de seguridad.
- La versión visible pasa a **v0.5**.

### Arreglos
- Ya no se crean cuentas por error al pedir un código con un email mal escrito.

### Base de datos
- **No hay cambios de SQL.** Si ya corriste `supabase.sql` de la v0.4, no hace falta volver a correrlo. Si todavía no, corré el de esta carpeta (es el mismo).
- **Sí hay cambios de configuración en el panel de Supabase** (una vez):
  1. Authentication → Sign In / Providers → apagar **Allow new users to sign up**.
  2. Authentication → Users → **Add user** para tu cuenta y la de cada amigo, con **Auto Confirm User** marcado.
- La plantilla del mail con código pasa a ser opcional (solo para "Entrar con un código por mail").

### Cómo actualizar
- **Primera publicación (todavía no publicaste la v0.4):** seguir `README.md` de esta carpeta de principio a fin.
- **Si ya tenías la v0.4 publicada:**
  1. Hacer los dos pasos de configuración de "Base de datos".
  2. Subir esta carpeta a Netlify con tu `config.js` completo adentro.

### Pendiente / conocido
- Si alguien se olvida la contraseña, se la cambia el administrador desde Supabase con el SQL del README; no hay "olvidé mi contraseña" automático (necesitaría un servicio de mails).
- Quien ya tiene la lista abierta ve las canciones agregadas recién al recargar la página.
- El QR necesita conexión a internet la primera vez que se dibuja.
- Las canciones con letra en formato ChordPro (acordes entre corchetes) ya se acomodaban al ancho; el cambio de esta versión es para el formato "acordes arriba de la letra".
- Supabase gratis pausa la base tras 7 días sin uso: abrir la app antes de la jam.
