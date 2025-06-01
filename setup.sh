#!/bin/bash

# Script para configurar el entorno de desarrollo
echo "🔧 Configurando entorno de desarrollo del Microservicio de Evaluaciones..."

# Crear archivo .env desde el ejemplo
if [ ! -f .env ]; then
    echo "📝 Creando archivo .env desde .env.example..."
    cp .env.example .env
    echo "✅ Archivo .env creado."
    echo ""
    echo "🔑 IMPORTANTE: Edita el archivo .env con tus credenciales reales:"
    echo "   - DATABASE_URL: URL de tu base de datos PostgreSQL"
    echo "   - DATABASE_USERNAME: Usuario de la base de datos"
    echo "   - DATABASE_PASSWORD: Contraseña de la base de datos"
    echo ""
    echo "💡 Para Railway, las credenciales están en tu dashboard:"
    echo "   https://railway.app/dashboard"
    echo ""
else
    echo "⚠️  El archivo .env ya existe. No se modificará."
fi

# Verificar permisos de scripts
echo "🔐 Verificando permisos de scripts..."
chmod +x start.sh
chmod +x check-status.sh
chmod +x setup.sh

echo ""
echo "✅ Configuración completada!"
echo ""
echo "📋 Próximos pasos:"
echo "   1. Edita .env con tus credenciales de base de datos"
echo "   2. Ejecuta ./start.sh para iniciar el microservicio"
echo "   3. Usa ./check-status.sh para verificar el estado"
echo ""
echo "🔒 Recuerda: NUNCA commits el archivo .env al repositorio"
