# 🔧 Solución: Error ENOENT index.html con PM2 start

## Problema
```
Error: ENOENT: no such file or directory, open '/srv/mystrapiapp/node_modules/@strapi/admin/dist/server/server/build/index.html'
```

Este error ocurre porque `npm run start` requiere que el panel de administración esté construido primero.

## Solución

### Opción 1: Construir antes de iniciar (si usas `start`)

```bash
# 1. Construir el proyecto
npm run build

# 2. Luego iniciar con PM2
pm2 start npm --name "strapi" -- start
```

### Opción 2: Usar `develop` en lugar de `start` (RECOMENDADO)

`develop` no requiere build y funciona mejor con PM2:

```bash
pm2 start npm --name "strapi" -- run develop
```

**Ventajas de usar `develop`:**
- ✅ No requiere `npm run build`
- ✅ Hot-reload automático (recarga cuando cambias código)
- ✅ Mejor para desarrollo
- ✅ Funciona directamente con PM2

### Opción 3: Script completo para setup

Si quieres usar `start` en producción, asegúrate de construir primero:

```bash
# En tu VM de Linux
cd /srv/mystrapiapp

# Construir el proyecto
npm run build

# Iniciar con PM2
pm2 start npm --name "strapi" -- start

# Ver logs
pm2 logs strapi
```

## Verificar que el build existe

```bash
# Verificar que existe el directorio build
ls -la node_modules/@strapi/admin/dist/server/server/build/

# Si no existe, construir
npm run build
```

## Diferencia entre `start` y `develop`

- **`develop`**: Modo desarrollo, no requiere build, hot-reload activo
- **`start`**: Modo producción, requiere `npm run build` primero, sin hot-reload

## Recomendación

Para desarrollo y testing, usa siempre `develop`:

```bash
pm2 start npm --name "strapi" -- run develop
```

Esto evitará el error y tendrás mejor experiencia de desarrollo.

