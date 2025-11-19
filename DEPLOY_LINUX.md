# 🐧 Guía de Despliegue en Linux VM

## Pasos para configurar el proyecto en tu VM de Linux

### 1. Clonar/Actualizar el repositorio

```bash
# Si es la primera vez
git clone [URL-DE-TU-REPO] strapi_serve
cd strapi_serve

# Si ya tienes el proyecto
git pull origin master
```

### 2. Instalar dependencias

```bash
npm install
```

### 3. Crear el archivo .env

Crea el archivo `.env` en la raíz del proyecto con el siguiente contenido:

```bash
nano .env
```

O usa este comando para crearlo directamente:

```bash
cat > .env << 'EOF'
# Database Configuration
DATABASE_CLIENT=postgres

# Supabase Connection Pooling (IPv4 compatible)
DATABASE_URL=postgresql://postgres.zckxyryyyybmiunpfgoj:jotamont1008@aws-1-us-east-2.pooler.supabase.com:6543/postgres

# SSL Configuration (requerido para Supabase)
DATABASE_SSL=true
DATABASE_SSL_REJECT_UNAUTHORIZED=false

# Database Schema
DATABASE_SCHEMA=public

# App Keys (generadas automáticamente)
APP_KEYS=eaHUZRoxZ/a44nu6RApacInHEPJJ+vO/e+erCXPhDNE=,KROxxTbF1GEnmPHdpb77MyhmoVPepbSATAM6sMtEvQs=,iL1tTWIGXaDgSsSHOZ2LvKsNBiuqOPnQ9YROpl2tLZU=,f805Cgved+Dekmja3mm6blcgAiU+EaCzpemwegV4kpA=

# Strapi Admin & Security Keys (requeridas)
ADMIN_JWT_SECRET=UUOR8/UTrYLgIl8YuL3cc9YzaMdtUo1PS8uR92isry0=
API_TOKEN_SALT=OW8Shoh7bDg9uO5Syb7iGxlrBNlnZrXkk+TV1PLTz+4=
TRANSFER_TOKEN_SALT=hgpkZC3hLV5O/1EpoaooEN6wSYx8zt1veQ9XsG7VfbY=
ENCRYPTION_KEY=obHWqzav3sU6DYNmS7oSnzlWeoq2EvbsRvVlm6xES7Y=

# Host and Port
HOST=0.0.0.0
PORT=1337
EOF
```

### 4. Verificar Node.js y npm

Asegúrate de tener Node.js versión 20-24:

```bash
node --version  # Debe ser >= 20.0.0 y <= 24.x.x
npm --version   # Debe ser >= 6.0.0
```

Si no tienes Node.js instalado:

```bash
# Usando nvm (recomendado)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc
nvm install 20
nvm use 20

# O usando el gestor de paquetes de tu distribución
# Ubuntu/Debian:
# curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
# sudo apt-get install -y nodejs
```

### 5. Construir el proyecto (producción)

```bash
npm run build
```

### 6. Iniciar Strapi

**Para desarrollo:**
```bash
npm run develop
```

**Para producción (con PM2):**
```bash
# Instalar PM2 globalmente si no lo tienes
npm install -g pm2

# Iniciar con PM2
pm2 start npm --name "strapi" -- start

# Ver logs
pm2 logs strapi

# Ver estado
pm2 status

# Guardar configuración para reinicio automático
pm2 save
pm2 startup
```

### 7. Configurar firewall (si es necesario)

Si necesitas acceder desde fuera de la VM:

```bash
# Ubuntu/Debian
sudo ufw allow 1337/tcp
sudo ufw reload
```

## Comandos útiles

### Reiniciar la aplicación
```bash
pm2 restart strapi
```

### Detener la aplicación
```bash
pm2 stop strapi
```

### Ver logs en tiempo real
```bash
pm2 logs strapi
```

### Verificar que está corriendo
```bash
curl http://localhost:1337
```

## Notas importantes

- El archivo `.env` **NO** se sube a git (está en `.gitignore`)
- Debes crear el `.env` manualmente en cada servidor/VM
- Las `APP_KEYS` deben ser las mismas en todos los entornos si compartes la misma base de datos
- Para producción, considera usar variables de entorno del sistema en lugar del archivo `.env`

