# 📋 Comandos Útiles para Linux

## Leer el archivo .env

### Ver todo el contenido
```bash
cat .env
```

### Ver con paginación (útil si es largo)
```bash
less .env
# Presiona 'q' para salir
```

### Ver las primeras líneas
```bash
head .env
# O ver las primeras 20 líneas
head -n 20 .env
```

### Ver las últimas líneas
```bash
tail .env
# O ver las últimas 20 líneas
tail -n 20 .env
```

### Buscar una variable específica
```bash
grep "DATABASE_URL" .env
grep "ADMIN_JWT_SECRET" .env
```

### Ver sin mostrar contraseñas (ocultar valores)
```bash
# Mostrar solo las claves, no los valores
grep -E "^[A-Z_]+=" .env | cut -d'=' -f1
```

### Editar el archivo .env
```bash
# Con nano (más fácil)
nano .env

# Con vim (más avanzado)
vim .env
# Presiona 'i' para insertar, 'Esc' luego ':wq' para guardar y salir
```

### Verificar que el .env existe
```bash
ls -la .env
# O
test -f .env && echo "✅ .env existe" || echo "❌ .env no existe"
```

### Contar cuántas variables hay
```bash
grep -c "^[A-Z_]*=" .env
```

### Ver el .env sin comentarios
```bash
grep -v "^#" .env | grep -v "^$"
```

## Comandos útiles adicionales

### Verificar que las variables estén cargadas
```bash
# Si usas dotenv o similar, puedes verificar con node
node -e "require('dotenv').config(); console.log(process.env.DATABASE_CLIENT)"
```

### Copiar el .env a otro archivo (backup)
```bash
cp .env .env.backup
```

### Comparar dos archivos .env
```bash
diff .env .env.backup
```

### Ver el tamaño del archivo
```bash
wc -l .env  # Número de líneas
ls -lh .env # Tamaño en bytes
```

