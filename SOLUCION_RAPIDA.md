# ⚡ Solución Rápida: Error index.html con PM2

## El problema
Cuando usas `pm2 start npm --name 'strapi' -- start`, necesitas haber construido el proyecto primero.

## Solución inmediata

### Opción 1: Construir y luego iniciar (si quieres usar `start`)

```bash
# 1. Detener PM2 si está corriendo
pm2 stop strapi
pm2 delete strapi

# 2. Construir el proyecto
npm run build

# 3. Iniciar con PM2
pm2 start npm --name "strapi" -- start

# 4. Ver logs
pm2 logs strapi
```

### Opción 2: Usar `develop` (MÁS FÁCIL - No requiere build)

```bash
# 1. Detener PM2 si está corriendo
pm2 stop strapi
pm2 delete strapi

# 2. Iniciar directamente con develop (no necesita build)
pm2 start npm --name "strapi" -- run develop

# 3. Ver logs
pm2 logs strapi
```

## ¿Cuál usar?

- **`develop`**: ✅ Más fácil, no requiere build, hot-reload
- **`start`**: Requiere `npm run build` primero, sin hot-reload

## Comando completo recomendado

```bash
# Detener si existe
pm2 delete strapi 2>/dev/null || true

# Iniciar con develop (recomendado)
pm2 start npm --name "strapi" -- run develop

# Ver logs
pm2 logs strapi
```

Esto debería funcionar inmediatamente sin necesidad de construir.

