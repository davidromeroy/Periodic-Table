#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"
# Comprobar si se pasó un argumento
if [ $# -eq 0 ]; then
    echo Please provide an element as an argument.
    exit 0
fi

# Obtener el argumento como entrada
input=$1

# Verificar si el argumento es un número
if [[ $input =~ ^[0-9]+$ ]]; then
    # Si es un número atómico
    ELEMENT=$($PSQL "SELECT e.atomic_number, e.symbol, e.name, 
                p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius, p.type_id 
                FROM elements e JOIN properties p ON e.atomic_number = p.atomic_number 
                WHERE e.atomic_number = $input")
else
    # Si es un símbolo o nombre
    ELEMENT=$($PSQL "SELECT e.atomic_number, e.symbol, e.name, 
                p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius, p.type_id 
                FROM elements e JOIN properties p ON e.atomic_number = p.atomic_number 
                WHERE e.symbol = '$input' OR LOWER(e.name) = LOWER('$input')")
fi

# Comprobar si se encontró el elemento
if [ -z "$ELEMENT" ]; then
    echo "I could not find that element in the database."
    exit 0
fi

# Dividir la cadena en variables
IFS='|' read -r ATOMIC_NUMBER SYMBOL NAME ATOMIC_MASS MELTING_POINT_CELSIUS BOILING_POINT_CELSIUS TYPE_ID<<< "$ELEMENT"

TYPE_ELEMENT=$($PSQL "SELECT type FROM types WHERE type_id = $TYPE_ID")

# Función para comprobar si la entrada es válida
check_element() {
    if [ "$1" -eq "$ATOMIC_NUMBER" ] || [ "$1" == "$SYMBOL" ] || [ "$1" == "$NAME" ]; then
        echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE_ELEMENT, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT_CELSIUS celsius and a boiling point of $BOILING_POINT_CELSIUS celsius."
        exit 0
    fi
}

# Comprobar la entrada
check_element "$input"
check_element "$1"

# Si no se encuentra el elemento
echo "Elemento no encontrado."
exit 0
