# Configuración de Supabase para Strapi

## Pasos para conectar Strapi con Supabase

### 1. Obtener las credenciales de Supabase

1. Ve a tu proyecto en [Supabase](https://supabase.com)
2. Navega a **Settings** > **Database**
3. En la sección **Connection string**, selecciona **URI** o **Connection pooling**
4. Copia la cadena de conexión

### 2. Crear archivo .env

Crea un archivo `.env` en la raíz del proyecto con el siguiente contenido:

```env
# Database Configuration
DATABASE_CLIENT=postgres

# Opción 1: Usar connection string de Supabase (recomendado)
DATABASE_URL=postgresql://postgres:[TU-CONTRASEÑA]@db.[TU-PROJECT-REF].supabase.co:5432/postgres

# Opción 2: Usar variables individuales (alternativa)
# DATABASE_HOST=db.[TU-PROJECT-REF].supabase.co
# DATABASE_PORT=5432
# DATABASE_NAME=postgres
# DATABASE_USERNAME=postgres
# DATABASE_PASSWORD=[TU-CONTRASEÑA]

# SSL Configuration (requerido para Supabase)
DATABASE_SSL=true
DATABASE_SSL_REJECT_UNAUTHORIZED=false

# Database Schema
DATABASE_SCHEMA=public

# App Keys (genera tus propias claves aleatorias)
APP_KEYS=toBeModified1,toBeModified2,toBeModified3,toBeModified4

# Host and Port
HOST=0.0.0.0
PORT=1337
```

### 3. Reemplazar los valores

- `[TU-CONTRASEÑA]`: Tu contraseña de la base de datos de Supabase
- `[TU-PROJECT-REF]`: El identificador de tu proyecto (lo encuentras en la URL de Supabase)
- `APP_KEYS`: Genera 4 claves aleatorias y seguras (puedes usar: `openssl rand -base64 32`)

### 4. Ejecutar migraciones

Después de configurar el `.env`, ejecuta:

```bash
npm run develop
```

Strapi detectará automáticamente la nueva base de datos y ejecutará las migraciones necesarias.

## Notas importantes

- **SSL es requerido**: Supabase requiere conexiones SSL, por eso `DATABASE_SSL=true`
- **Connection Pooling**: Si usas Supabase Connection Pooling, el puerto será `6543` en lugar de `5432`
- **Backup**: Asegúrate de hacer backup de tu base de datos SQLite actual si tienes datos importantes antes de migrar

