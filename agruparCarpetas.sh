#!/bin/bash

# --- Validación de Argumentos ---
# Se asegura de que el script reciba exactamente dos argumentos.
if [ "$#" -ne 2 ]; then
    echo "Error: Se requieren dos argumentos."
    echo "Uso: $0 <directorio> <tamaño_del_grupo>"
    exit 1
fi

# --- Asignación de Variables ---
# Asigna los argumentos a variables con nombres claros para mejorar la legibilidad.
DIRECTORIO_BASE=$1
TAMANO_GRUPO=$2

# --- Verificación del Directorio ---
# Comprueba si el directorio proporcionado realmente existe.
if [ ! -d "$DIRECTORIO_BASE" ]; then
    echo "Error: El directorio '$DIRECTORIO_BASE' no existe."
    exit 1
fi

echo "Analizando el directorio: $DIRECTORIO_BASE"
echo "Tamaño de grupo establecido en: $TAMANO_GRUPO"
echo "--------------------------------------------------"

# --- Determinar el Rango de Carpetas ---
# Busca la carpeta con el número más alto para saber hasta dónde debe operar.
# `ls -v` lista ordenando numéricamente (1, 2, ..., 10, 11 en vez de 1, 10, 11, 2).
# `grep -E '^[0-9]+$'` se asegura de que solo procesemos nombres que son puramente numéricos.
# `tail -n 1` obtiene el último de la lista, que será el número más alto.
ULTIMA_CARPETA=$(ls -v "$DIRECTORIO_BASE" | grep -E '^[0-9]+$' | tail -n 1)

# Si no se encuentra ninguna carpeta numerada, informa al usuario y termina.
if [ -z "$ULTIMA_CARPETA" ]; then
    echo "⚠️ No se encontraron carpetas numeradas para agrupar en '$DIRECTORIO_BASE'."
    exit 0
fi

echo "La carpeta con el número más alto es: $ULTIMA_CARPETA. Iniciando agrupación..."
echo ""

# --- Bucle Principal de Agrupación ---
# Este bucle itera en saltos del tamaño del grupo (ej: 1, 6, 11, ... si el tamaño es 5).
for (( i=1; i<=ULTIMA_CARPETA; i+=TAMANO_GRUPO )); do
    # Define el inicio del rango.
    inicio=$i
    # Calcula el final del rango.
    fin=$((i + TAMANO_GRUPO - 1))

    # Ajusta el final si supera el número de la última carpeta existente.
    if [ "$fin" -gt "$ULTIMA_CARPETA" ]; then
        fin=$ULTIMA_CARPETA
    fi

    # Crea el nombre para la nueva carpeta contenedora (ej: "1-5").
    NOMBRE_GRUPO="${inicio}-${fin}"
    RUTA_GRUPO="$DIRECTORIO_BASE/$NOMBRE_GRUPO"

    # Crea la carpeta contenedora.
    echo "Creando grupo: $NOMBRE_GRUPO"
    mkdir "$RUTA_GRUPO"

    # --- Bucle Interno para Mover Carpetas ---
    # Itera a través de cada número dentro del rango actual (ej: 1, 2, 3, 4, 5).
    for (( j=inicio; j<=fin; j++ )); do
        CARPETA_ORIGEN="$DIRECTORIO_BASE/$j"
        # Mueve la carpeta solo si existe.
        if [ -d "$CARPETA_ORIGEN" ]; then
            mv "$CARPETA_ORIGEN" "$RUTA_GRUPO/"
            echo "  -> Moviendo '$j' a '$NOMBRE_GRUPO'"
        fi
    done
    echo "" # Añade un espacio para mayor claridad en la salida.
done

echo "¡Proceso de agrupación completado con éxito!"