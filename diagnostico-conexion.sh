#!/bin/bash

# Script para diagnosticar problemas de conexión a Supabase
# Uso: ./diagnostico-conexion.sh

set -e

echo "🔍 Diagnóstico de conexión a Supabase"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Verificar si .env existe
if [ ! -f .env ]; then
    echo "❌ El archivo .env no existe!"
    exit 1
fi

# Extraer información del .env
if grep -q "DATABASE_URL" .env; then
    DB_URL=$(grep "DATABASE_URL" .env | cut -d'=' -f2- | tr -d '"' | tr -d "'" | tr -d ' ')
    
    # Extraer componentes de la URL
    HOST=$(echo "$DB_URL" | sed -n 's/.*@\([^:]*\):.*/\1/p')
    PORT=$(echo "$DB_URL" | sed -n 's/.*:\([0-9]*\)\/.*/\1/p')
    
    echo "📋 Información de conexión:"
    echo "   Host: $HOST"
    echo "   Puerto: $PORT"
    echo ""
    
    # Verificar resolución DNS
    echo "🌐 Verificando resolución DNS..."
    if command -v nslookup &> /dev/null; then
        echo "   Resolución IPv4:"
        nslookup "$HOST" 2>/dev/null | grep -A 2 "Name:" || echo "   ⚠️  No se pudo resolver"
        echo ""
        echo "   Resolución IPv6:"
        nslookup -type=AAAA "$HOST" 2>/dev/null | grep -A 2 "Name:" || echo "   ℹ️  No hay registro IPv6 (esto es normal)"
    elif command -v host &> /dev/null; then
        echo "   IPv4:"
        host "$HOST" 2>/dev/null || echo "   ⚠️  No se pudo resolver"
        echo ""
        echo "   IPv6:"
        host -t AAAA "$HOST" 2>/dev/null || echo "   ℹ️  No hay registro IPv6"
    else
        echo "   ⚠️  nslookup/host no disponibles"
    fi
    echo ""
    
    # Probar conectividad con telnet/nc
    echo "🔌 Probando conectividad al puerto $PORT..."
    if command -v nc &> /dev/null; then
        if timeout 5 nc -zv -4 "$HOST" "$PORT" 2>&1; then
            echo "   ✅ Conexión IPv4 exitosa"
        else
            echo "   ❌ No se pudo conectar por IPv4"
        fi
        echo ""
        
        # Probar IPv6
        if timeout 5 nc -zv -6 "$HOST" "$PORT" 2>&1; then
            echo "   ✅ Conexión IPv6 exitosa"
        else
            echo "   ⚠️  No se pudo conectar por IPv6 (puede ser normal)"
        fi
    elif command -v telnet &> /dev/null; then
        echo "   Probando con telnet (timeout 5 segundos)..."
        timeout 5 telnet "$HOST" "$PORT" </dev/null 2>&1 | head -3 || echo "   ❌ No se pudo conectar"
    else
        echo "   ⚠️  nc/telnet no disponibles para probar conectividad"
    fi
    echo ""
    
    # Verificar firewall
    echo "🔥 Verificando firewall local..."
    if command -v iptables &> /dev/null && [ "$EUID" -eq 0 ]; then
        echo "   Reglas de firewall (primeras 5):"
        iptables -L -n | head -10
    elif command -v ufw &> /dev/null; then
        echo "   Estado de UFW:"
        ufw status | head -5
    else
        echo "   ℹ️  No se pudo verificar firewall (se requieren permisos de root)"
    fi
    echo ""
    
    # Probar con curl si está disponible
    echo "🌍 Probando acceso HTTP a Supabase..."
    if command -v curl &> /dev/null; then
        API_URL="https://${HOST%%.*}.supabase.co"
        if curl -s -o /dev/null -w "   Código HTTP: %{http_code}\n" --connect-timeout 5 "$API_URL" 2>/dev/null; then
            echo "   ✅ Supabase es accesible"
        else
            echo "   ⚠️  No se pudo acceder a la API de Supabase"
        fi
    fi
    echo ""
    
    # Verificar configuración de red
    echo "📡 Información de red del sistema:"
    if command -v ip &> /dev/null; then
        echo "   Interfaces de red:"
        ip -4 addr show | grep -E "inet |inet6 " | head -5
    elif command -v ifconfig &> /dev/null; then
        echo "   Interfaces de red:"
        ifconfig | grep -E "inet |inet6 " | head -5
    fi
    echo ""
    
    # Sugerencias
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "💡 Sugerencias para solucionar el problema:"
    echo ""
    echo "1. Verificar conectividad a internet:"
    echo "   ping -c 3 8.8.8.8"
    echo ""
    echo "2. Verificar que el firewall permita conexiones salientes:"
    echo "   sudo ufw allow out 5432/tcp"
    echo ""
    echo "3. Forzar IPv4 en la conexión (si hay problemas con IPv6):"
    echo "   Edita config/database.ts para usar solo IPv4"
    echo ""
    echo "4. Verificar que la VM tenga acceso a internet:"
    echo "   curl -I https://www.google.com"
    echo ""
    echo "5. Probar conexión directa con psql (si está instalado):"
    echo "   psql \"$DB_URL\" -c 'SELECT version();'"
    echo ""
    
else
    echo "❌ DATABASE_URL no encontrado en .env"
    exit 1
fi

