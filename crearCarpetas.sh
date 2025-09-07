#!/bin/bash

# Verifica si el número de argumentos es correcto (deben ser 2)
if [ "$#" -ne 2 ]; then
    echo "Uso: $0 <ruta_del_directorio> <numero_de_carpetas>"
    exit 1
fi

# Asigna los argumentos a variables para mayor claridad
directorio_base=$1
cantidad_carpetas=$2

# Verifica si el directorio base existe. Si no, lo crea.
if [ ! -d "$directorio_base" ]; then
    echo "El directorio '$directorio_base' no existe. Creándolo..."
    mkdir -p "$directorio_base"
fi

# Bucle 'for' que se ejecuta desde 1 hasta el número de carpetas indicado
for (( i=1; i<=cantidad_carpetas; i++ ))
do
    # Crea la carpeta con el nombre del número actual dentro del directorio base
    mkdir "$directorio_base/$i"
    echo "Carpeta creada: $directorio_base/$i"
done

echo "¡Proceso completado!"