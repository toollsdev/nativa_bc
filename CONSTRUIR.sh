#!/bin/bash

echo "Escolha a plataforma para build:"
echo "1 - Android"
echo "2 - iOS"
read -p "Opção: " opcao

if [ "$opcao" == "1" ]; then
    echo "🔧 Construindo APK Android..."
    flutter build appbundle --release
elif [ "$opcao" == "2" ]; then
    echo "🔧 Construindo para iOS..."
    flutter build ios --release
else
    echo "❌ Opção inválida."
fi

