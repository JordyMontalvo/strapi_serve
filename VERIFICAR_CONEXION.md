# 🔍 Cómo Verificar que Strapi está Conectado a Supabase

## Método 1: Script Automatizado (Más Fácil)

En tu VM de Linux, ejecuta:

```bash
./verificar-conexion.sh
```

Este script verificará:
- ✅ Que el archivo `.env` existe
- ✅ Que `DATABASE_CLIENT=postgres`
- ✅ Que `DATABASE_URL` está configurado
- ✅ Que SSL está habilitado
- ✅ La conexión real a Supabase
- ✅ Si las tablas de Strapi ya existen

## Método 2: Verificar desde Strapi

### Paso 1: Iniciar Strapi

```bash
npm run develop
```

### Paso 2: Revisar los logs

Busca en los logs estas líneas:

```
[INFO] Database connected
[INFO] Server started on port 1337
```

Si ves errores de conexión, verifica tu `.env`.

### Paso 3: Verificar en Supabase Dashboard

1. Ve a [Supabase Dashboard](https://supabase.com/dashboard)
2. Selecciona tu proyecto
3. Ve a **Table Editor**
4. Deberías ver tablas que empiezan con `strapi_` como:
   - `strapi_core_store_settings`
   - `strapi_webhooks`
   - `strapi_migrations`
   - Y más...

## Método 3: Verificar desde la Terminal (con psql)

Si tienes `psql` instalado:

```bash
# Conectar directamente a Supabase
psql "postgresql://postgres:jotamont1008@db.zckxyryyyybmiunpfgoj.supabase.co:5432/postgres?sslmode=require"

# Una vez conectado, listar tablas de Strapi:
\dt strapi_*

# O ver todas las tablas:
\dt

# Salir:
\q
```

## Método 4: Verificar con Node.js

Crea un archivo temporal `test-connection.js`:

```javascript
const { Client } = require('pg');
require('dotenv').config();

const client = new Client({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false }
});

client.connect()
  .then(() => {
    console.log('✅ Conexión exitosa a Supabase!');
    return client.query("SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name LIKE 'strapi_%'");
  })
  .then((res) => {
    console.log('\n📊 Tablas de Strapi encontradas:');
    res.rows.forEach(row => console.log('   -', row.table_name));
    if (res.rows.length === 0) {
      console.log('   (Aún no hay tablas. Ejecuta npm run develop para crearlas)');
    }
    client.end();
  })
  .catch((err) => {
    console.error('❌ Error:', err.message);
    process.exit(1);
  });
```

Ejecuta:

```bash
node test-connection.js
```

## Método 5: Verificar Variables de Entorno

```bash
# Verificar que .env tiene las variables correctas
cat .env | grep DATABASE

# Deberías ver:
# DATABASE_CLIENT=postgres
# DATABASE_URL=postgresql://postgres:...
# DATABASE_SSL=true
```

## Señales de que SÍ está conectado a Supabase:

✅ Los logs de Strapi muestran "Database connected"  
✅ En Supabase Dashboard > Table Editor ves tablas `strapi_*`  
✅ No hay errores de conexión en los logs  
✅ El script de verificación muestra "Conexión exitosa"  

## Señales de que NO está conectado:

❌ Errores como "Connection refused" o "ECONNREFUSED"  
❌ Errores de autenticación  
❌ No hay tablas en Supabase Dashboard  
❌ Los logs muestran que está usando SQLite  

## Solución de Problemas

### Error: "Connection refused"
- Verifica que `DATABASE_URL` esté correcto
- Verifica que el firewall permita conexiones salientes al puerto 5432

### Error: "password authentication failed"
- Verifica la contraseña en `DATABASE_URL`
- Asegúrate de que la contraseña no tenga caracteres especiales sin codificar

### Error: "SSL required"
- Asegúrate de que `DATABASE_SSL=true` en tu `.env`

### No se crean tablas
- Ejecuta `npm run develop` (no `npm run start`)
- La primera vez, Strapi crea las tablas automáticamente

