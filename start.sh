#!/bin/bash

# Script de arranque para el microservicio de evaluaciones
echo "🚀 Iniciando Microservicio de Evaluaciones..."

# Verificar si existe archivo .env
if [ -f .env ]; then
    echo "📋 Cargando variables de entorno desde .env..."
    export $(cat .env | grep -v '^#' | xargs)
else
    echo "⚠️  Archivo .env no encontrado. Usando valores por defecto."
    echo "💡 Copia .env.example a .env y configura tus credenciales."
fi

echo "📦 Compilando proyecto..."
mvn clean compile

if [ $? -eq 0 ]; then
    echo "✅ Compilación exitosa"
    echo "🌟 Iniciando aplicación en puerto 8083..."
    echo "🔗 Base de datos: ${DATABASE_URL:-'localhost (default)'}"
    mvn spring-boot:run
else
    echo "❌ Error en la compilación"
    exit 1
fi
