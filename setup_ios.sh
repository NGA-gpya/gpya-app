#!/bin/bash

# GPYA iOS Setup Script
# Run this on your Mac to prepare the project for compilation.

echo "🚀 Iniciando preparación para iOS..."

# 1. Obtener dependencias de Flutter
echo "📦 Obteniendo paquetes de Flutter..."
flutter pub get

# 2. Limpiar cache de iOS (opcional pero recomendado)
echo "🧹 Limpiando configuraciones previas..."
rm -rf ios/Pods
rm -f ios/Podfile.lock

# 3. Instalar CocoaPods
echo "🍎 Instalando dependencias de iOS (CocoaPods)..."
cd ios
pod install
cd ..

# 4. Generar iconos (asegura que estén sincronizados)
echo "✨ Generando iconos de la aplicación..."
dart run flutter_launcher_icons

echo "✅ Proyecto listo para abrir en Xcode."
echo "👉 Abre 'ios/Runner.xcworkspace' en tu Xcode y presiona Play."
