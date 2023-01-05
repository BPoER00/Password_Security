#!/bin/bash


#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

#ruta donde se guardara el fichero
ruta="$(echo ~/Desktop/Passwords)"

#para imprimir
valor="$(cat $ruta | tr '_' ' ' | tr '&' '_')"

trap ctrl_c INT

function printTable(){

    local -r delimiter="${1}"
    local -r data="$(removeEmptyLines "${2}")"

    if [[ "${delimiter}" != '' && "$(isEmptyString "${data}")" = 'false' ]]
    then
        local -r numberOfLines="$(wc -l <<< "${data}")"

        if [[ "${numberOfLines}" -gt '0' ]]
        then
            local table=''
            local i=1

            for ((i = 1; i <= "${numberOfLines}"; i = i + 1))
            do
                local line=''
                line="$(sed "${i}q;d" <<< "${data}")"

                local numberOfColumns='0'
                numberOfColumns="$(awk -F "${delimiter}" '{print NF}' <<< "${line}")"

                if [[ "${i}" -eq '1' ]]
                then
                    table="${table}$(printf '%s#+' "$(repeatString '#+' "${numberOfColumns}")")"
                fi

                table="${table}\n"

                local j=1

                for ((j = 1; j <= "${numberOfColumns}"; j = j + 1))
                do
                    table="${table}$(printf '#| %s' "$(cut -d "${delimiter}" -f "${j}" <<< "${line}")")"
                done

                table="${table}#|\n"

                if [[ "${i}" -eq '1' ]] || [[ "${numberOfLines}" -gt '1' && "${i}" -eq "${numberOfLines}" ]]
                then
                    table="${table}$(printf '%s#+' "$(repeatString '#+' "${numberOfColumns}")")"
                fi
            done

            if [[ "$(isEmptyString "${table}")" = 'false' ]]
            then
                echo -e "${table}" | column -s '#' -t | awk '/^\+/{gsub(" ", "-", $0)}1'
            fi
        fi
	fi
}

function removeEmptyLines(){

    local -r content="${1}"
    echo -e "${content}" | sed '/^\s*$/d'
}

function repeatString(){

    local -r string="${1}"
    local -r numberToRepeat="${2}"

    if [[ "${string}" != '' && "${numberToRepeat}" =~ ^[1-9][0-9]*$ ]]
    then
        local -r result="$(printf "%${numberToRepeat}s")"
        echo -e "${result// /${string}}"
    fi
}

function isEmptyString(){

    local -r string="${1}"

    if [[ "$(trimString "${string}")" = '' ]]
    then
        echo 'true' && return 0
    fi

    echo 'false' && return 1
}

function trimString(){

    local -r string="${1}"
    sed 's,^[[:blank:]]*,,' <<< "${string}" | sed 's,[[:blank:]]*$,,'
}

function ctrl_c( ){
	echo -e "\n${redColour}[!] Saliendo...\n${endColour}"
	tput cnorm; exit 1
}

function helpPanel(){
	echo -e "\n${redColour}[!] Uso: ./passwords${endColour}"
	for i in $(seq 1 80); do echo -ne "${redColour}-"; done; echo -ne "${endColour}" 

	echo -e "\n\n\t${blueColour}-------------------------[${endColour}${greenColour} FUNCIONES DEL SISTEMA ${endColour}${blueColour}]-------------------------${endColour}"
    echo -e "\n\n\t${blueColour}|${endColour}${greenColour} PASSWORD ${endColour}${blueColour}|${endColour}"
    echo -e "\n\t\t${blueColour}[${endColour}${turquoiseColour}-p${endColour}${blueColour}]${endColour}\t${yellowColour}-[Lista Que Password Tenemos]-${endColour}"    
    echo -e "\n\t\t${blueColour}[${endColour}${turquoiseColour}-c${endColour}${blueColour}]${endColour}\t${yellowColour}-[Crea Password]-${endColour}"    
    echo -e "\n\t\t${blueColour}[${endColour}${turquoiseColour}-d${endColour}${blueColour}]${endColour}\t${yellowColour}-[Revela Password]-${endColour}"    

	tput cnorm
}

function listarPassword(){
    find $ruta > /dev/null 2>&1
    if [ "$(echo $? )" == "1" ]; then
        echo -e "\n${redColour}[!] Aun no has ingresado ningun tipo de data (No Existe El Fichero)...\n${endColour}"
    else
        if [ "$(cat $ruta | wc -l)" == "0" ]; then
            echo -e "\n${redColour}[!] Aun no has ingresado ningun tipo de data... (Fichero Vacio)\n${endColour}"
        else
            echo -e ${yellowColour}
            echo -e "\t [CUENTA] \t\t[USUARIO]"
            printTable ' ' "$(cat $ruta | awk '{print $1, $2}')"
            echo -e ${endColour}
        fi
    fi
}

function crearPassword(){
	echo -e "\n\n\t${blueColour}-------------------------[${endColour}${greenColour} INGRESE DATOS ${endColour}${blueColour}]-------------------------${endColour}"
    echo -ne "\n\t${blueColour}|${endColour}${greenColour} CUENTA ${endColour}${blueColour}|${endColour} = " && read cuenta
    echo -ne "\n\t${blueColour}|${endColour}${greenColour} USUARIO ${endColour}${blueColour}|${endColour} = " && read usuario
    echo -ne "\n\t${blueColour}|${endColour}${greenColour} CORREO ${endColour}${blueColour}|${endColour} = " && read correo
    echo -ne "\n\t${blueColour}|${endColour}${greenColour} PASSWORD ${endColour}${blueColour}|${endColour} = " && read password
    clear

    cuenta=$(echo $cuenta | tr ' ' '&')
    usuario=$(echo $usuario | tr ' ' '&')
    correo=$(echo $correo | tr ' ' '&')

    cuenta=$(echo $cuenta | tr '_' '&')
    usuario=$(echo $usuario | tr '_' '&')
    correo=$(echo $correo | tr '_' '&')

    
    valor=$(echo password | openssl enc -aes-256-cbc -md sha512 -a -pbkdf2 -iter 100000 -salt -pass pass:'pick.your.password')
    echo "|Cuenta_"$cuenta"| |Usuario_"$usuario"| |Correo_"$correo"| |Password_"$valor"|$(\n)" >> $ruta

}

function verPassword(){
    echo "ver"
}

if [ "$(id -u)" == 0 ]; then

declare -i parameter_counter=0; while getopts "p:c:d:h:" arg; do

	case $arg in
		p) opcion_p=$OPTARG; let parameter_counter+=1 ;;
		c) opcion_c=$OPTARG; let parameter_counter+=1 ;;
		d) opcion_d=$OPTARG; let parameter_counter+=1 ;;
		h) helpPanel;;
	esac

done

    if [ $parameter_counter -eq 0 ]; then
        helpPanel
    else
    clear
        if [ "$(echo $opcion_p)" == "PASSWORD" ]; then
            listarPassword
        elif [ "$(echo $opcion_c)" == "PASSWORD" ]; then
            crearPassword
        elif [ "$(echo $opcion_d)" == "PASSWORD" ]; then
            verPassword
        fi
    fi
else
    echo -e "\n${redColour}[!] Error: Necesitas ser administrador para ejecutar este programa${endColour}"
	echo -e "${redColour}[!] Saliendo... ${endColour}"
fi
