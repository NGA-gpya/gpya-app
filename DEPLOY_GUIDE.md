# Guía de Despliegue CI/CD (Codemagic + GitHub)

He configurado la aplicación para que pueda ser compilada automáticamente en la nube. Sin embargo, por seguridad, hay ciertos **Secretos (Variables de Entorno)** que tú debes cargar manualmente en el panel de Codemagic.

## 🔑 Variables Requeridas en Codemagic

Debes crear dos grupos de variables en **Codemagic > Application Settings > Environment Variables**:

### 1. Grupo: `supabase_config`
Configura estas variables para que la app pueda conectarse a tu base de datos:
- `SUPABASE_URL`: La URL de tu proyecto en Supabase.
- `SUPABASE_ANON_KEY`: La llave anónima de tu proyecto.

### 2. Grupo: `google_play_credentials` (Solo Android)
Para firmar la aplicación de Android:
- `ANDROID_KEYSTORE_BASE64`: El contenido de tu archivo `.jks` convertido a Base64.
- `ANDROID_KEY_PASSWORD`: La contraseña de tu almacén de llaves.
- `ANDROID_KEY_ALIAS`: El alias de tu llave (ej: `upload`).

### 3. Grupo: `appstore_credentials` (Solo iOS)
- Sigue las instrucciones de Codemagic para conectar tu cuenta de Apple Developer y generar los API Keys necesarios.

---

## 🛠️ Mejoras Técnicas Realizadas
- **Android Workflow**: Añadido soporte para generar `.apk` y `.aab` (App Bundle para la Play Store).
- **iOS Workflow**: Actualizado para inyectar las llaves de Supabase automáticamente.
- **Inyección de Código**: Ahora usamos `--dart-define`, lo que significa que **no tienes que subir tus llaves al código fuente**, lo que hace tu repositorio de GitHub mucho más seguro.
- **Corrección de Gestos**: Se habilitó `enableOnBackInvokedCallback` para una navegación perfecta en Android 13+.

---

> [!IMPORTANT]
> **Antes de compilar**: Asegúrate de que el nombre del grupo de variables en Codemagic coincida exactamente con los nombres que puse arriba (`supabase_config`, etc.).
