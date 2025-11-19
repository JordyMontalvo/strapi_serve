# 🚀 Comandos PM2 para Strapi

## Iniciar Strapi con PM2

```bash
# Iniciar con develop (recomendado)
pm2 start npm --name "strapi" -- run develop
```

## Comandos útiles de PM2

### Ver estado
```bash
pm2 status
# o
pm2 list
```

### Ver logs
```bash
# Ver logs en tiempo real
pm2 logs strapi

# Ver últimas 100 líneas
pm2 logs strapi --lines 100

# Ver logs sin colores
pm2 logs strapi --no-color
```

### Reiniciar
```bash
# Reiniciar la aplicación
pm2 restart strapi

# Reiniciar todas las aplicaciones
pm2 restart all
```

### Detener
```bash
# Detener la aplicación
pm2 stop strapi

# Detener todas las aplicaciones
pm2 stop all
```

### Eliminar
```bash
# Eliminar de PM2
pm2 delete strapi

# Eliminar todas
pm2 delete all
```

### Monitoreo
```bash
# Ver monitoreo en tiempo real
pm2 monit

# Ver información detallada
pm2 show strapi
```

### Guardar y auto-inicio
```bash
# Guardar la configuración actual
pm2 save

# Configurar para que PM2 inicie al arrancar el sistema
pm2 startup
# Sigue las instrucciones que aparecen
```

### Recargar (zero-downtime)
```bash
# Recargar sin detener (solo funciona con cluster mode)
pm2 reload strapi
```

## Solución de problemas

### Si PM2 no inicia correctamente
```bash
# Ver logs de error
pm2 logs strapi --err

# Verificar que el proceso está corriendo
ps aux | grep strapi

# Reiniciar PM2 completamente
pm2 kill
pm2 start npm --name "strapi" -- run develop
```

### Limpiar logs
```bash
# Limpiar todos los logs
pm2 flush
```

### Ver uso de recursos
```bash
# Ver CPU y memoria
pm2 monit
```

## Nota importante

⚠️ **Usar `develop` en lugar de `start`**: 
- `develop` es para desarrollo y tiene hot-reload
- `start` es para producción pero puede tener problemas con PM2
- Con `develop` tendrás recarga automática de cambios

