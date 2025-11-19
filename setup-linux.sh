#!/bin/bash

# Script para configurar Strapi en Linux VM
# Uso: ./setup-linux.sh

set -e

echo "🚀 Configurando Strapi en Linux VM..."

# Verificar si Node.js está instalado
if ! command -v node &> /dev/null; then
    echo "❌ Node.js no está instalado. Por favor instálalo primero."
    echo "   Visita: https://nodejs.org/ o usa nvm"
    exit 1
fi

# Verificar versión de Node.js
NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 20 ] || [ "$NODE_VERSION" -gt 24 ]; then
    echo "⚠️  Advertencia: Node.js versión $NODE_VERSION. Se recomienda versión 20-24."
fi

echo "✅ Node.js $(node -v) detectado"

# Verificar si npm está instalado
if ! command -v npm &> /dev/null; then
    echo "❌ npm no está instalado."
    exit 1
fi

echo "✅ npm $(npm -v) detectado"

# Verificar si .env existe
if [ -f .env ]; then
    echo "⚠️  El archivo .env ya existe. ¿Deseas sobrescribirlo? (s/n)"
    read -r response
    if [[ ! "$response" =~ ^[Ss]$ ]]; then
        echo "❌ Operación cancelada."
        exit 0
    fi
fi

# Crear archivo .env
echo "📝 Creando archivo .env..."
cat > .env << 'ENVFILE'
# Database Configuration
DATABASE_CLIENT=postgres

# Supabase Connection Pooling (IPv4 compatible)
# Usar connection pooling que funciona con IPv4
DATABASE_URL=postgresql://postgres.zckxyryyyybmiunpfgoj:jotamont1008@aws-1-us-east-2.pooler.supabase.com:6543/postgres

# Opción alternativa: Variables individuales (si prefieres no usar connection string)
# DATABASE_HOST=aws-1-us-east-2.pooler.supabase.com
# DATABASE_PORT=6543
# DATABASE_NAME=postgres
# DATABASE_USERNAME=postgres.zckxyryyyybmiunpfgoj
# DATABASE_PASSWORD=jotamont1008

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
ENVFILE

echo "✅ Archivo .env creado"

# Instalar dependencias
echo "📦 Instalando dependencias..."
npm install

echo "✅ Dependencias instaladas"

# Construir el proyecto
echo "🔨 Construyendo el proyecto..."
npm run build

echo "✅ Proyecto construido"

echo ""
echo "✨ Configuración completada!"
echo ""
echo "Para iniciar Strapi:"
echo "  Desarrollo: npm run develop"
echo "  Producción: npm run start"
echo ""
echo "O con PM2:"
echo "  pm2 start npm --name 'strapi' -- start"
echo ""

