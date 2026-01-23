# Guía de Despliegue - Servidor AlmaLinux 9.7

## 📋 Tabla de Contenidos

- [Información del Servidor](#información-del-servidor)
- [Instalación de Node.js con NVM](#instalación-de-nodejs-con-nvm)
- [Instalación de PM2](#instalación-de-pm2)
- [Instalación de Nginx](#instalación-de-nginx)
- [Configuración de Proyectos](#configuración-de-proyectos)
- [Configuración de Certificados SSL](#configuración-de-certificados-ssl)
- [Configuración de Nginx con HTTPS](#configuración-de-nginx-con-https)
- [Configuración de Firewall](#configuración-de-firewall)
- [Solución de Problemas Comunes](#solución-de-problemas-comunes)
- [Comandos Útiles](#comandos-útiles)

---

## 🖥️ Información del Servidor

- **Sistema Operativo**: AlmaLinux 9.7 (Moss Jungle Cat)
- **IP del Servidor**: `10.30.11.248`
- **Usuario**: `bserrano`
- **Hostname**: `VMBIBAPPDES01.aiep.corp`

### Proyectos Desplegados

| Proyecto | Dominio | Puerto | Framework |
|----------|---------|--------|-----------|
| CMS Biblioteca (Strapi) | `cmsbibliotecatest.aiep.cl` | 1337 | Strapi 5.31.0 |
| Portal Biblioteca | `portal-bibliotecatest.aiep.cl` | 3000 | Node.js/Express |

---

## 📦 Instalación de Node.js con NVM

### 1. Instalar NVM vía Git (recomendado para entornos con SSL corporativo)

```bash
# Clonar repositorio de NVM
git clone git@github.com:nvm-sh/nvm.git ~/.nvm

# Cambiar a versión estable
cd ~/.nvm
git checkout v0.39.7
```

### 2. Configurar NVM en el sistema

```bash
# Agregar al .bashrc
nano ~/.bashrc
```

Agregar al final del archivo:

```bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
```

Recargar configuración:

```bash
source ~/.bashrc
```

### 3. Instalar Node.js 22 (LTS)

```bash
# Instalar Node 22
nvm install 22

# Usar Node 22
nvm use 22

# Establecer como predeterminado
nvm alias default 22

# Verificar instalación
node -v  # Debe mostrar v22.x.x
npm -v
```

---

## 🔄 Instalación de PM2

PM2 es un gestor de procesos para aplicaciones Node.js en producción.

```bash
# Instalar PM2 globalmente
npm install -g pm2

# Verificar instalación
pm2 -v
```

### Configurar PM2 para arranque automático

```bash
# Generar script de inicio
pm2 startup

# Ejecutar el comando que PM2 muestra (ejemplo):
sudo env PATH=$PATH:/home/bserrano/.nvm/versions/node/v22.x.x/bin pm2 startup systemd -u bserrano --hp /home/bserrano

# Guardar configuración actual
pm2 save
```

---

## 🌐 Instalación de Nginx

```bash
# Redirección HTTP a HTTPS
server {
    listen 80;
    server_name portal-bibliotecatest.aiep.cl;
    return 301 https://$host$request_uri;
}

# Configuración HTTPS - Proxy a PM2 (puerto 3000) y Strapi (puerto 1337)
server {
    listen 443 ssl http2;
    server_name portal-biblioteca.aiep.cl test.portal-biblioteca.aiep.cl;

    # Rutas de los certificados SSL
    ssl_certificate /etc/ssl/aiep/wildcard_aiep_cl.crt;
    ssl_certificate_key /etc/ssl/aiep/wildcard_aiep_cl.key;
    ssl_trusted_certificate /etc/ssl/aiep/wildcard_aiep_cl-ca.crt;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    # Headers de seguridad
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Proxy para la aplicación Vue.js corriendo en PM2
    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Port $server_port;

        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";

        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;

        proxy_buffering off;
    }

    # Proxy para API (Strapi)
    location /api {
        proxy_pass http://127.0.0.1:1337;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Port $server_port;

        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Proxy para admin de Strapi
    location /admin {
        proxy_pass http://127.0.0.1:1337;
        proxy_http_version 1.1;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;

        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    access_log /var/log/nginx/biblioteca-access.log;
    error_log /var/log/nginx/biblioteca-error.log;
}

#### 4. Configurar Vite para dominios externos

Crear o editar `src/admin/vite.config.ts`:

```typescript
import { defineConfig } from 'vite';

export default defineConfig({
  server: {
    allowedHosts: [
      'cmsbibliotecatest.aiep.cl',
      'portal-bibliotecatest.aiep.cl'
    ]
  }
});
```

#### 5. Iniciar con PM2

```bash
# Para desarrollo
pm2 start npm --name cmsbiblioteca -- run develop

# Para producción (recomendado)
npm run build
pm2 start npm --name cmsbiblioteca -- run start
```

### Portal Biblioteca

#### 1. Navegar al proyecto

```bash
cd ~/DisenoBiblioteca/portal-biblioteca
```

#### 2. Instalar dependencias

```bash
npm install
```

#### 3. Iniciar con PM2

```bash
pm2 start npm --name biblioteca-aiep -- run start
```

### Verificar procesos PM2

```bash
pm2 list
pm2 logs cmsbiblioteca
pm2 logs biblioteca-aiep
```

---

## 🔐 Configuración de Certificados SSL

### 1. Localizar el archivo PFX

Primero, encuentra dónde está ubicado tu certificado `.pfx`:

```bash
# Buscar en el directorio home del usuario
find ~ -name "wildcard_aiep_cl.pfx"

# O buscar en todo el sistema
sudo find / -name "wildcard_aiep_cl.pfx"
```

**Resultado esperado**: `/etc/nginx/ssl/wildcard_aiep_cl.pfx`

### 2. Crear directorio seguro para certificados

Nginx no puede leer archivos dentro de `/root`, por lo que creamos un directorio accesible:

```bash
sudo mkdir -p /etc/ssl/aiep
```

### 3. Convertir PFX a formato Nginx

⚠️ **Problema común**: Error con algoritmo RC2-40-CBC

Si obtienes este error:

```text
error:0308010C:digital envelope routines:inner_evp_generic_fetch:unsupported
Algorithm (RC2-40-CBC : 0), Properties ()
```

**Causa**: El archivo PFX usa cifrado antiguo (RC2-40-CBC) que OpenSSL 3.x no soporta por defecto.

**Solución**: Usar la opción `-legacy`

#### Extraer clave privada

```bash
# Habilitar compatibilidad con algoritmos legacy
export OPENSSL_CONF=/etc/ssl/openssl.cnf

# Extraer clave privada (sin contraseña)
sudo openssl pkcs12 -in /etc/nginx/ssl/wildcard_aiep_cl.pfx \
  -nocerts -nodes \
  -out /etc/ssl/aiep/wildcard_aiep_cl.key \
  -legacy
```

**Nota**: Se te pedirá la contraseña del archivo PFX.

#### Extraer certificado del servidor

```bash
sudo openssl pkcs12 -in /etc/nginx/ssl/wildcard_aiep_cl.pfx \
  -clcerts -nokeys \
  -out /etc/ssl/aiep/wildcard_aiep_cl.crt \
  -legacy
```

#### Extraer cadena de certificados (CA Bundle)

```bash
sudo openssl pkcs12 -in /etc/nginx/ssl/wildcard_aiep_cl.pfx \
  -cacerts -nokeys -chain \
  -out /etc/ssl/aiep/wildcard_aiep_cl-ca.crt \
  -legacy
```

### 4. Configurar permisos correctos

```bash
# Establecer propietario (root:nginx)
sudo chown root:nginx /etc/ssl/aiep/wildcard_aiep_cl.*

# Permisos para clave privada (solo root y nginx pueden leer)
sudo chmod 640 /etc/ssl/aiep/wildcard_aiep_cl.key

# Permisos para certificados (lectura pública)
sudo chmod 644 /etc/ssl/aiep/wildcard_aiep_cl.crt
sudo chmod 644 /etc/ssl/aiep/wildcard_aiep_cl-ca.crt
```

### 5. Verificar certificados

#### Verificar que la clave y el certificado coinciden

```bash
# Hash del certificado
openssl x509 -noout -modulus -in /etc/ssl/aiep/wildcard_aiep_cl.crt | openssl md5

# Hash de la clave privada
openssl rsa -noout -modulus -in /etc/ssl/aiep/wildcard_aiep_cl.key | openssl md5
```

**Los hashes deben ser idénticos**. Si no coinciden, la clave y el certificado no son compatibles.

#### Verificar la cadena de certificados

```bash
openssl verify -CAfile /etc/ssl/aiep/wildcard_aiep_cl-ca.crt \
  /etc/ssl/aiep/wildcard_aiep_cl.crt
```

**Resultado esperado**: `wildcard_aiep_cl.crt: OK`

#### Verificar información del certificado

```bash
openssl x509 -in /etc/ssl/aiep/wildcard_aiep_cl.crt -noout -subject -dates
```

**Resultado esperado**:

```text
subject=CN=*.aiep.cl
notBefore=...
notAfter=...
```

### 6. Limpiar archivos sensibles (opcional)

```bash
# Eliminar archivo de contraseña si existe
sudo rm -f /etc/nginx/ssl/Pass.txt

# Eliminar PFX original (opcional, después de verificar que todo funciona)
# sudo rm -f /etc/nginx/ssl/wildcard_aiep_cl.pfx
```

---

## ⚙️ Configuración de Nginx con HTTPS

### CMS Biblioteca (Strapi)

Crear archivo `/etc/nginx/conf.d/cmsbiblioteca.conf`:

```nginx
# Redirección HTTP → HTTPS
server {
    listen 80;
    server_name cmsbibliotecatest.aiep.cl;
    return 301 https://$host$request_uri;
}

# Servidor HTTPS
server {
    listen 443 ssl;
    server_name cmsbibliotecatest.aiep.cl;

    # Certificados SSL
    ssl_certificate     /etc/nginx/ssl/wildcard_aiep_cl.crt;
    ssl_certificate_key /etc/nginx/ssl/wildcard_aiep_cl.key;

    # Configuración SSL moderna
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    # Headers de seguridad
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;

    # Proxy a Strapi
    location / {
        proxy_pass http://127.0.0.1:1337;
        proxy_http_version 1.1;

        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;

        proxy_cache_bypass $http_upgrade;
    }
}
```

### Portal Biblioteca

Crear archivo `/etc/nginx/conf.d/portal-biblioteca.conf`:

```nginx
# Redirección HTTP → HTTPS
server {
    listen 80;
    server_name portal-bibliotecatest.aiep.cl;
    return 301 https://$host$request_uri;
}

# Servidor HTTPS
server {
    listen 443 ssl;
    server_name portal-bibliotecatest.aiep.cl;

    # Certificados SSL
    ssl_certificate     /etc/nginx/ssl/wildcard_aiep_cl.crt;
    ssl_certificate_key /etc/nginx/ssl/wildcard_aiep_cl.key;

    # Configuración SSL moderna
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    # Headers de seguridad
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;

    # Proxy a Node.js
    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;

        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;

        proxy_cache_bypass $http_upgrade;
    }
}
```

### Validar y recargar Nginx

```bash
# Validar configuración
sudo nginx -t

# Si todo está OK, recargar
sudo systemctl reload nginx

# Verificar puertos
ss -lntp | grep -E ':80|:443'
```

---

## 🔥 Configuración de Firewall

### Verificar estado del firewall

```bash
sudo firewall-cmd --state
```

### Abrir puertos necesarios

```bash
# Agregar servicios HTTP y HTTPS
sudo firewall-cmd --add-service=http --permanent
sudo firewall-cmd --add-service=https --permanent

# Recargar firewall
sudo firewall-cmd --reload

# Verificar configuración
sudo firewall-cmd --list-all
```

### Configurar SELinux para Nginx

```bash
# Permitir que Nginx se conecte a backends
sudo setsebool -P httpd_can_network_connect on

# Verificar estado
getsebool httpd_can_network_connect
```

---

## 🔧 Solución de Problemas Comunes

### Error: SSL certificate problem

**Problema**: Git/curl no puede verificar certificados SSL

**Causa**: Firewall corporativo (Fortinet) intercepta conexiones HTTPS

**Solución**: Usar SSH en lugar de HTTPS

```bash
# Clonar repositorios por SSH
git clone git@github.com:usuario/repo.git

# O configurar Git para usar IPv4
export NODE_OPTIONS=--dns-result-order=ipv4first
```

### Error: Connection refused (puerto 1337/3000)

**Problema**: PM2 no está ejecutando las aplicaciones

**Diagnóstico**:

```bash
# Verificar procesos PM2
pm2 list

# Ver logs
pm2 logs cmsbiblioteca --lines 50

# Verificar puertos
ss -lntp | grep -E '1337|3000'
```

**Solución**:

```bash
# Reiniciar aplicación
pm2 restart cmsbiblioteca

# O iniciar si no está corriendo
pm2 start npm --name cmsbiblioteca -- run develop
```

### Error: 502 Bad Gateway

**Problema**: Nginx no puede conectarse al backend

**Diagnóstico**:

```bash
# Ver logs de Nginx
sudo tail -f /var/log/nginx/error.log

# Probar backend directamente
curl http://127.0.0.1:1337
curl http://127.0.0.1:3000
```

**Soluciones posibles**:

1. **SELinux bloqueando**:
   ```bash
   sudo setsebool -P httpd_can_network_connect on
   ```

2. **Backend caído**:
   ```bash
   pm2 restart all
   ```

3. **Puerto incorrecto en Nginx**:
   Verificar `proxy_pass` en configuración

### Error: Blocked request (Vite/Strapi)

**Problema**: Vite bloquea el dominio externo

**Solución**: Configurar `allowedHosts` en `src/admin/vite.config.ts`:

```typescript
import { defineConfig } from 'vite';

export default defineConfig({
  server: {
    allowedHosts: [
      'cmsbibliotecatest.aiep.cl',
      'portal-bibliotecatest.aiep.cl'
    ]
  }
});
```

Luego reiniciar:

```bash
pm2 restart cmsbiblioteca
```

### Error: ENETUNREACH (IPv6)

**Problema**: Base de datos usa IPv6 pero el servidor solo tiene IPv4

**Solución**: Usar IP IPv4 directa en `.env`:

```env
# ❌ NO usar hostname
DATABASE_HOST=mydb.amazonaws.com

# ✅ Usar IP IPv4
DATABASE_HOST=10.20.30.40
```

Y forzar IPv4 en Node:

```bash
export NODE_OPTIONS=--dns-result-order=ipv4first
pm2 restart cmsbiblioteca --update-env
```

### Problema de Seguridad: CORS Permisivo (Arbitrary Origin)

**Problema**: La API responde con `Access-Control-Allow-Origin` para cualquier origen (ej. `https://random.com`) y `Access-Control-Allow-Credentials: true`.

**Causa**: Nginx está inyectando headers CORS inseguros que sobrescriben la configuración segura de Strapi.

**Diagnóstico**:
Verificar si Nginx tiene headers configurados:
```bash
grep -R "Access-Control-Allow-Origin" /etc/nginx/
```

**Solución**:
1. Editar la configuración de Nginx (`/etc/nginx/conf.d/cmsbiblioteca.conf` o `/etc/nginx/nginx.conf`).
2. **Eliminar** o comentar líneas como:
   ```nginx
   add_header Access-Control-Allow-Origin *; # ❌ ELIMINAR
   add_header Access-Control-Allow-Credentials true; # ❌ ELIMINAR
   ```
3. Nginx **NO** debe manejar CORS; Strapi ya lo hace correctamente en `config/middlewares.ts`.
4. Recargar Nginx:
   ```bash
   sudo nginx -t
   sudo systemctl reload nginx
   ```

---

## 📝 Comandos Útiles

### PM2

```bash
# Listar procesos
pm2 list

# Ver logs en tiempo real
pm2 logs

# Ver logs de un proceso específico
pm2 logs cmsbiblioteca

# Reiniciar proceso
pm2 restart cmsbiblioteca

# Detener proceso
pm2 stop cmsbiblioteca

# Eliminar proceso
pm2 delete cmsbiblioteca

# Monitoreo en tiempo real
pm2 monit

# Guardar configuración actual
pm2 save

# Información detallada de un proceso
pm2 info cmsbiblioteca
```

### Nginx

```bash
# Validar configuración
sudo nginx -t

# Recargar configuración (sin downtime)
sudo systemctl reload nginx

# Reiniciar servicio
sudo systemctl restart nginx

# Ver estado
sudo systemctl status nginx

# Ver logs de error
sudo tail -f /var/log/nginx/error.log

# Ver logs de acceso
sudo tail -f /var/log/nginx/access.log

# Ver configuración completa cargada
sudo nginx -T

# Buscar configuraciones de un dominio
grep -R "cmsbiblioteca" /etc/nginx/
```

### Sistema

```bash
# Ver puertos en uso
ss -lntp

# Ver puertos específicos
ss -lntp | grep -E ':80|:443|:1337|:3000'

# Ver procesos Node
ps aux | grep node

# Verificar DNS
dig cmsbibliotecatest.aiep.cl +short
getent hosts cmsbibliotecatest.aiep.cl

# Verificar conectividad
curl -I http://127.0.0.1:1337
curl -I https://cmsbibliotecatest.aiep.cl

# Ver uso de recursos
htop
```

### Firewall

```bash
# Ver estado
sudo firewall-cmd --state

# Listar configuración
sudo firewall-cmd --list-all

# Listar puertos abiertos
sudo firewall-cmd --list-ports

# Listar servicios permitidos
sudo firewall-cmd --list-services

# Recargar firewall
sudo firewall-cmd --reload
```

### SELinux

```bash
# Ver estado
getenforce

# Ver booleanos relacionados con HTTP
getsebool -a | grep httpd

# Verificar configuración específica
getsebool httpd_can_network_connect
```

---

## 🎯 Checklist de Despliegue

- [ ] Node.js 22 instalado con NVM
- [ ] PM2 instalado globalmente
- [ ] Nginx instalado y habilitado
- [ ] Firewall configurado (puertos 80, 443)
- [ ] SELinux configurado (`httpd_can_network_connect`)
- [ ] Certificados SSL convertidos y con permisos correctos
- [ ] Strapi configurado con variables de entorno correctas
- [ ] Vite configurado con `allowedHosts`
- [ ] Nginx configurado para ambos dominios
- [ ] PM2 configurado para arranque automático
- [ ] Aplicaciones iniciadas con PM2
- [ ] HTTPS funcionando correctamente
- [ ] Redirección HTTP → HTTPS activa

---

## 📚 Referencias

- [AlmaLinux Documentation](https://wiki.almalinux.org/)
- [NVM GitHub](https://github.com/nvm-sh/nvm)
- [PM2 Documentation](https://pm2.keymetrics.io/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [Strapi Documentation](https://docs.strapi.io/)
- [Let's Encrypt](https://letsencrypt.org/)

---

## 📞 Soporte

Para problemas o consultas:

- **Usuario del servidor**: `bserrano`
- **Hostname**: `VMBIBAPPDES01.aiep.corp`
- **IP**: `10.30.11.248`

---

**Última actualización**: 2026-01-15
