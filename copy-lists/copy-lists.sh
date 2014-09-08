#! /bin/bash 

# Colors constants
NONE="$(tput sgr0)"
RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
YELLOW="$(tput setaf 3)"
BLUE="$(tput setaf 4)"

message () {
    # $1 : Message
    # $2 : Color
    # return : Message colorized

    echo -e "${2}${1}${NONE}"
}

DROPBOX_DIR=/home/gabriel/Dropbox

case $2 in
    "") 
        RADIO_DIR='/home/gabriel/Documents/radios/La_Nota_Azul' 
        ;;
    /*)
        RADIO_DIR=$2
        ;;
    *)
        message "$2 debe ser path absoluto!" $RED
        exit 1
        ;;
esac

message "cambeo a: ${RADIO_DIR}" $BLUE
cd ${RADIO_DIR}

for program in $(ls -v | grep "programa$1")
do
    if [ -d $program ] 
    then 
        message "estoy en: ${RADIO_DIR}/$program" $NONE
        temp=${program:8} 
        tempfec=$(ls $program | awk /lista_de_temas_[0-9]{6}$/'{print substr($1, 16)}') 
        NAME="LNA - Lista de temas programa $temp - $tempfec.txt" 
        if [ -z "$temp" ] 
        then    
            message "temp nulo: $program" $RED
            continue
        else
            if [ -z "$tempfec" ]
            then
                message "no se armo lista de programa $temp" $RED
            elif [ -f "$program/$NAME" ]
            then
                message "programa $temp: lista bella ya existe!" $YELLOW
            elif [ $(cat $program/lista_de_temas_$tempfec|grep 'se pasó'|wc -l) -eq 0 ]
            then 
                message "programa $temp todavía no se emitió!" $YELLOW
                continue
            else
                message "creo $program/$NAME" $GREEN
                cat $program/lista_de_temas_$tempfec|head -1|awk -F'-' /-/'{print $1"-"$2"-"$3"-"$4"-"$5}' > $program/"$NAME"
                cat $program/lista_de_temas_$tempfec|head -2|tail -n1|awk -F' ' /-/'{print $1"   "$2"   "$3"   "$4"   "$5"\n"}' >> $program/"$NAME"
                echo -e "Link a grooveshark: \n" >> $program/"$NAME"
                tail -n+3 $program/lista_de_temas_$tempfec|grep 'se pasó'|awk -F' - ' /-/'{print $1" - "$2" - "$3" - "$4" - "$5"\n"}' >> $program/"$NAME"
                python /home/gabriel/scripts/pasar_a_windows.py $RADIO_DIR/$program/"$NAME"
            fi
            if ! [ -h $DROPBOX_DIR/"$NAME" -o -e $DROPBOX_DIR/"$NAME" ] 
            then
                message "creo enlace simbólico en $DROPBOX_DIR/$NAME" $GREEN
                ln -sf $RADIO_DIR/$program/"$NAME" $DROPBOX_DIR
            fi
        fi 
    fi
done

exit 0
