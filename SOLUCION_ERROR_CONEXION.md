# 🔧 Solución: Error ENETUNREACH / Problemas de conexión a Supabase

## Problema
```
Error: connect ENETUNREACH
2600:1f16:1cd0:333e:470e:21e4:5ded:b4f6:5432 - Local (:::0)
```

Este error indica que la VM de Linux no puede conectarse a Supabase, generalmente por problemas con IPv6 o conectividad de red.

## Soluciones

### Solución 1: Usar variables individuales en lugar de DATABASE_URL (Recomendado)

El problema puede ser que `DATABASE_URL` está causando que el driver intente usar IPv6. Usa variables individuales en su lugar.

**Edita tu archivo `.env` en la VM de Linux:**

```bash
nano .env
```

**Reemplaza o comenta la línea `DATABASE_URL` y agrega estas variables:**

```env
# Database Configuration
DATABASE_CLIENT=postgres

# Supabase Connection Pooling (IPv4 compatible - RECOMENDADO)
DATABASE_URL=postgresql://postgres.zckxyryyyybmiunpfgoj:jotamont1008@aws-1-us-east-2.pooler.supabase.com:6543/postgres

# Opción alternativa: Variables individuales (si prefieres no usar connection string)
# DATABASE_HOST=aws-1-us-east-2.pooler.supabase.com
# DATABASE_PORT=6543
# DATABASE_NAME=postgres
# DATABASE_USERNAME=postgres.zckxyryyyybmiunpfgoj
# DATABASE_PASSWORD=jotamont1008

# SSL Configuration
DATABASE_SSL=true
DATABASE_SSL_REJECT_UNAUTHORIZED=false
DATABASE_SCHEMA=public
```

**O usa este comando para actualizar automáticamente:**

```bash
# Backup del .env actual
cp .env .env.backup

# Agregar variables individuales
cat >> .env << 'EOF'

# Variables individuales para evitar problemas con IPv6
DATABASE_HOST=db.zckxyryyyybmiunpfgoj.supabase.co
DATABASE_PORT=5432
DATABASE_NAME=postgres
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=jotamont1008
EOF

# Comentar DATABASE_URL si existe
sed -i 's/^DATABASE_URL=/#DATABASE_URL=/' .env
```

### Solución 2: Verificar conectividad de red

Ejecuta el script de diagnóstico:

```bash
./diagnostico-conexion.sh
```

O verifica manualmente:

```bash
# Verificar resolución DNS
nslookup db.zckxyryyyybmiunpfgoj.supabase.co

# Probar conectividad al puerto
nc -zv db.zckxyryyyybmiunpfgoj.supabase.co 5432

# Verificar acceso a internet
ping -c 3 8.8.8.8
curl -I https://www.google.com
```

### Solución 3: Configurar firewall

Si el firewall está bloqueando conexiones salientes:

```bash
# Ubuntu/Debian con UFW
sudo ufw allow out 5432/tcp
sudo ufw reload

# O deshabilitar temporalmente para probar
sudo ufw disable  # Solo para diagnóstico
```

### Solución 4: Deshabilitar IPv6 temporalmente

Si tu VM no tiene conectividad IPv6, puedes deshabilitarla temporalmente:

```bash
# Deshabilitar IPv6 (requiere root)
sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1

# Para hacerlo permanente, edita /etc/sysctl.conf
```

**⚠️ Nota:** Esto puede afectar otras aplicaciones que usen IPv6.

### Solución 5: Verificar configuración de red de la VM

Asegúrate de que tu VM tenga:
- Acceso a internet
- DNS configurado correctamente
- Rutas de red configuradas

```bash
# Verificar configuración de red
ip addr show
ip route show

# Verificar DNS
cat /etc/resolv.conf
```

## Después de aplicar la solución

1. **Reinicia Strapi:**
   ```bash
   pm2 restart strapi
   # o
   npm run develop
   ```

2. **Verifica los logs:**
   ```bash
   pm2 logs strapi
   # o revisa la salida de npm run develop
   ```

3. **Prueba la conexión:**
   ```bash
   ./diagnostico-conexion.sh
   ```

## Prevención

Para evitar este problema en el futuro:
- Usa siempre variables individuales (`DATABASE_HOST`, etc.) en lugar de `DATABASE_URL`
- Asegúrate de que la VM tenga conectividad IPv4 a internet
- Configura el firewall correctamente desde el inicio

