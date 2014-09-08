#!/usr/bin/env bash

# TODO: agregar la capacidad de saltar un pipe.
# Hay que reescribir las funciones de los colores, 
# armar una sola que reciba 3 parametros (el string, 
# el color y si va en negrita o no), y armar variables 
# globales para manejar eso. Con esto me fijo si estoy 
# antes de un pipe o no:
# echo $$; ls -l /proc/$$/fd/1

if [ "$#" -lt 1 ]
then
    echo "nada para buscar, chau"
    exit 1
fi

LNA_DIR=/home/gabriel/Documents/radios/La_Nota_Azul
TEMPFILE=$(tempfile)
WC_TEMPFILE=$(tempfile)
WATCH_ARRAY=( [0]='\b|' [1]='\b/' [2]='\b-' [3]='\b\' )
let POS=0

echo-ne () { echo -ne $*; }

buscar=$*
#for i in "$@"
#do 
#    buscar+="$i "
#done 
#aca le quito el ultimo espacio en blanco
#let len=${#buscar}-1
#buscar=${buscar:0:$len}

busqueda () {
# BAD HACK: el {1..1000} es para que salga ordenado por fecha. 
# *HAY* que cambiarlo para que sea dinámico, pero sin tener que 
# buscar en todos los números de programas.
# BAD HACK: chequear una forma de pasar la variable LNA_DIR a 
# awk para no tener que hacer ese doble matcheo, creo que puede
# ser la opción -v.

    grep -EIis "$buscar"'.*se pasó' "${LNA_DIR}"/programa{1..1000}/* | awk -F " - " \
    '
        function red(s) {
            printf "\033[2;31m" s "\033[0m "
        }

        function red_bold(s) {
            printf "\033[1;31m" s "\033[0m "
        }

        function green(s) {
            printf "\033[2;32m" s "\033[0m "
        }

        function green_bold(s) {
            printf "\033[1;32m" s "\033[0m "
        }

        function blue(s) {
            printf "\033[2;34m" s "\033[0m "
        }

        function blue_bold(s) {
            printf "\033[1;34m" s "\033[0m "
        }
    
        function light_blue(s) {
            printf "\033[2;36m" s "\033[0m "
        }
        
        function light_blue_bold(s) {
            printf "\033[1;36m" s "\033[0m "
        }
    
        function magenta(s) {
            printf "\033[2;35m" s "\033[0m "
        }
    
        function magenta_bold(s) {
            printf "\033[1;35m" s "\033[0m "
        }
    
        function white_bold(s) {
            printf "\033[1;37m" s "\033[0m "
        }

        {
        if (match($0, /[0-9]{6}/, A) && match($0, /programa[0-9]+/, J)) print\
                red("Programa N°: ") red_bold(substr(J[0], 9))\
                blue("\nFecha: ") blue_bold(substr(A[0], 0, 2)"/"substr(A[0], 3, 2)"/"substr(A[0], 5))\
                green("\nCanción: ") green_bold($2)\
                light_blue("\nArtista: ") light_blue_bold($3)\
                magenta("\nDisco: ") magenta_bold($4)\
                white_bold("\n---------------------------------")
        }
    ' | tee $TEMPFILE | wc -l
}

echo-ne "\nLooking for: \"$buscar\"... ."
busqueda > $WC_TEMPFILE &
pid=$!

while ps --pid=$pid > /dev/null 
do 
    echo-ne "${WATCH_ARRAY[$POS]}"
    env sleep 0.2
    let POS+=1
    [ "$POS" -le 3 ] || let POS=0
done

total_lines=$(cat $WC_TEMPFILE)
if [ $total_lines -eq 0 ]
then 
    echo -e '\b\033[2;31mNothing found :(\033[0m'
else
    let found=${total_lines}/6
    echo -e "\b\033[2;32mDone! Found ${found} coincidences:\033[0m\n"
    cat $TEMPFILE 
fi

echo -e '\nCleaning up!'
rm $TEMPFILE $WC_TEMPFILE
echo 'Goodbye'

exit 0
