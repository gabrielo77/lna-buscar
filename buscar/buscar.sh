#!/usr/bin/env bash

#set -eu

if [ "$#" -lt 1 ]
then
    echo "nada para buscar, chau"
    exit 1
fi

MY_PID=$$
LNA_DIR=/home/gabriel/Documents/radios/La_Nota_Azul
TEMPFILE=$(tempfile)
WC_TEMPFILE=$(tempfile)
WATCH_ARRAY=( [0]='\b|' [1]='\b/' [2]='\b-' [3]='\b\' )
POS=0 # POS is the position in the array above, the subscript
STDOUT_POINTS_PIPE=$(ls -l /proc/$MY_PID/fd/1 | grep -i pipe | wc -l)

#set -o pipefail

echo-ne () { echo -ne $*; }

buscar=$*

busqueda () {
# BAD HACK: el {1..1000} es para que salga ordenado por fecha. 
# *HAY* que cambiarlo para que sea dinámico, pero sin tener que 
# buscar en todos los números de programas. En realidad ahora
# que lo pienso parece imposible, mejor dejarlo asi, no creo 
# que llegue a los 1000 programas je.
# BAD HACK: chequear una forma de pasar la variable LNA_DIR a 
# awk para no tener que hacer ese doble matcheo, creo que puede
# ser la opción -v. Aunque por otro lado el doble matcheo sirve
# para no complicar la salida de las fechas y programas.
# TODO: crear una sola funcion que imprima los colores.

    grep -EIis "$buscar"'.*se pasó' "${LNA_DIR}"/programa{1..1000}/* | awk -F " - " -v PIPE=$STDOUT_POINTS_PIPE \
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
        if (match($0, /[0-9]{6}/, DATE) && match($0, /programa[0-9]+/, PROGRAM)) 
            { 
            if (PIPE == 0) print\
                red("Programa N°: ") red_bold(substr(PROGRAM[0], 9))\
                blue("\nFecha: ") blue_bold(substr(DATE[0], 0, 2)"/"substr(DATE[0], 3, 2)"/"substr(DATE[0], 5))\
                green("\nCanción: ") green_bold($2)\
                light_blue("\nArtista: ") light_blue_bold($3)\
                magenta("\nDisco: ") magenta_bold($4)\
                white_bold("\n-------------------------------------------------")
            else print\
                "Programa N°: " substr(PROGRAM[0], 9)\
                "\nFecha: " substr(DATE[0], 0, 2)"/"substr(DATE[0], 3, 2)"/"substr(DATE[0], 5)\
                "\nCanción: " $2\
                "\nArtista: " $3\
                "\nDisco: " $4\
                "\n-------------------------------------------------"
            }
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

if [ $STDOUT_POINTS_PIPE -eq 0 ]
then
    red='\033[2;31m'
    goback='\033[0m'
    green='\033[2;32m'
else
    red=''
    goback=''
    green=''
fi

total_lines=$(cat $WC_TEMPFILE)
if [ $total_lines -eq 0 ]
then 
    echo -e '\b'$red'Nothing found :<('$goback
else
    let found=${total_lines}/6
    echo -e '\b'$green"Done! Found ${found} coincidences:"$goback'\n'
    cat $TEMPFILE 
fi

echo -e '\nCleaning up!'
rm $TEMPFILE $WC_TEMPFILE
echo 'Goodbye'

exit 0
