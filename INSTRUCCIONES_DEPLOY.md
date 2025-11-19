# 🚀 Instrucciones Rápidas de Despliegue

## Pasos para desplegar en tu VM de Linux

### 1. Subir cambios a Git (desde tu máquina local)

```bash
git add .
git commit -m "Configurar conexión a Supabase con pooler IPv4 compatible"
git push origin master
```

### 2. En tu VM de Linux

```bash
# Actualizar código
git pull origin master

# Ejecutar script de configuración
chmod +x setup-linux.sh
./setup-linux.sh
```

El script `setup-linux.sh` ahora usa la connection string del **pooler de Supabase** que es compatible con IPv4:
```
postgresql://postgres.zckxyryyyybmiunpfgoj:jotamont1008@aws-1-us-east-2.pooler.supabase.com:6543/postgres
```

### 3. Verificar conexión

```bash
# Ejecutar diagnóstico
chmod +x diagnostico-conexion.sh
./diagnostico-conexion.sh
```

### 4. Iniciar Strapi

```bash
# Desarrollo
npm run develop

# O producción con PM2
pm2 start npm --name "strapi" -- start
pm2 logs strapi
```

## ✅ Ventajas del Connection Pooler

- ✅ **Compatible con IPv4** - No tendrás problemas de conectividad
- ✅ **Mejor rendimiento** - El pooler maneja las conexiones eficientemente
- ✅ **Puerto 6543** - Puerto específico para connection pooling
- ✅ **Más estable** - Diseñado para aplicaciones en producción

## 🔍 Si hay problemas

Revisa el archivo `SOLUCION_ERROR_CONEXION.md` para soluciones detalladas.

