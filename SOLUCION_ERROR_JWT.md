# 🔧 Solución: Error Missing admin.auth.secret

## Problema
```
Error: Missing admin.auth.secret configuration. The SessionManager requires a JWT secret
```

## Solución

Este error ocurre porque faltan las variables de entorno de seguridad requeridas por Strapi. Necesitas agregar estas variables a tu archivo `.env` en la VM de Linux.

### Opción 1: Agregar manualmente al .env existente

En tu VM de Linux, edita el archivo `.env`:

```bash
nano .env
```

Y agrega estas líneas al final del archivo:

```env
# Strapi Admin & Security Keys (requeridas)
ADMIN_JWT_SECRET=UUOR8/UTrYLgIl8YuL3cc9YzaMdtUo1PS8uR92isry0=
API_TOKEN_SALT=OW8Shoh7bDg9uO5Syb7iGxlrBNlnZrXkk+TV1PLTz+4=
TRANSFER_TOKEN_SALT=hgpkZC3hLV5O/1EpoaooEN6wSYx8zt1veQ9XsG7VfbY=
ENCRYPTION_KEY=obHWqzav3sU6DYNmS7oSnzlWeoq2EvbsRvVlm6xES7Y=
```

Guarda el archivo (Ctrl+X, luego Y, luego Enter en nano).

### Opción 2: Ejecutar el script actualizado

Si ejecutas el script `setup-linux.sh` actualizado, ya incluirá estas variables automáticamente.

### Opción 3: Agregar con un comando

```bash
cat >> .env << 'EOF'

# Strapi Admin & Security Keys (requeridas)
ADMIN_JWT_SECRET=UUOR8/UTrYLgIl8YuL3cc9YzaMdtUo1PS8uR92isry0=
API_TOKEN_SALT=OW8Shoh7bDg9uO5Syb7iGxlrBNlnZrXkk+TV1PLTz+4=
TRANSFER_TOKEN_SALT=hgpkZC3hLV5O/1EpoaooEN6wSYx8zt1veQ9XsG7VfbY=
ENCRYPTION_KEY=obHWqzav3sU6DYNmS7oSnzlWeoq2EvbsRvVlm6xES7Y=
EOF
```

## Después de agregar las variables

1. **Reinicia Strapi** si está corriendo:
   ```bash
   # Si usas PM2
   pm2 restart strapi
   
   # O si lo ejecutaste directamente
   # Detén el proceso (Ctrl+C) y vuelve a iniciar:
   npm run develop
   # o
   npm run start
   ```

2. **Verifica que funciona**:
   ```bash
   # Ver logs
   pm2 logs strapi
   # o simplemente verifica que no hay errores al iniciar
   ```

## Variables explicadas

- **ADMIN_JWT_SECRET**: Clave secreta para firmar los tokens JWT del panel de administración
- **API_TOKEN_SALT**: Salt para generar tokens de API
- **TRANSFER_TOKEN_SALT**: Salt para tokens de transferencia de datos
- **ENCRYPTION_KEY**: Clave para encriptar datos sensibles

**⚠️ Importante**: Estas claves deben ser las mismas en todos los entornos si compartes la misma base de datos, o diferentes si son entornos separados.

