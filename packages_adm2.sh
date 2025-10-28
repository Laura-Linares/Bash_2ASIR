#! /bin/bash

#----Author:LauraLinares-----
#---------Version:1.0--------
#---Script:packages_adm2.sh---
#---Uso: upgrade de packages_adm.sh haciendo uso de getopt---


#--Declaración de funciones--
usage() {
    cat << EOF
Uso: $0 [OPCIONES] [ARGUMENTOS]

Script para la creación de direcorios, descarga de enlaces y su posterior descompresión, compresión de una carpeta de trabajo para la creación de una copia de seguridad y/o la recuperación de una copia de seguridad realizada previamente.

Opciones:
    -a, --accion ACCION           Acción que se realizará (obligatorio)
    -e, --enlace ENLACE           Enlace con el archivo comprimido para descargar
    -d, --directorio DIRECTORIO   Directorio de trabajo en /opt
    -h, --help                    Muestra este mensaje de ayuda

Ejemplos:
    $0 -a nuevaconfig -d apache
    $0 -a descargar -d apache -e https://....
    $0 --accion cerrar --directorio apache
    $0 -a recuperar -d apache
EOF
    exit 1
}

last_error_control() {
    #Controla que el último proceso haya sido exitoso
    if [ $? -eq 0 ]; then
        echo "La acción se ha completado sin fallos"
    else
        echo "Ha ocurrido un error durante la ejecución de esta acción"
        exit 1
    fi
}

package_installation() {
    #Comprueba que los paquetes necesarios estén instalados
    for i in wget gzip bzip2; do
        if ! command -V "$i" >/dev/null 2>&1; then
            echo "Instalando $i"
            sudo apt-get update -qq
            sudo apt-get install -y -qq "$i"
        fi
    done
}

#--Declaración de variables--
accion=""
enlace=""
directorio=""

#------Inicio del script-----
    #Analiza opciones de línea de comandos
OPTS=$(getopt -o a:e:d:h --long accion:,enlace:,directorio:,help -- "$@")

if [ $? -ne 0 ]; then
    echo "Error al analizar opciones" >&2
    usage
fi

eval set -- "$OPTS"

    #Procesa las opciones
while true; do
    case "$1" in
        -a | --accion)
            accion="$2"
            shift 2
            ;;
        -e | --enlace)
            enlace="$2"
            shift 2
            ;;
        -d | --directorio)
            directorio="$2"
            shift 2
            ;;
        -h | --help)
            usage
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Se ha producido un error interno"
            exit 1
            ;;
    esac
done

    #Controla que se pase la opcion obligatoria (accion)
if [ -z "$accion" ]; then
    echo "Error: Debe especificarse una acción con -a o --accion" >&2
    usage
fi

    #Manejo de las distintas opciones
case "$opcion" in
    nuevaconfig | nuevaconfiguracion)
            #Comprueba si el directorio existe
        if [ ! -d "/opt/$directorio" ]; then
            echo "Error, el directorio \"$directorio\" que está intentando crear, ya existe"
            exit 1
        fi

            #Crea el directorio
        sudo mkdir /opt/$directorio

        last_error_control
        ;;
    descargar)
                #Comprueba si existe el directorio donde desea descargar
        if [ -d "/opt/$directorio" ]; then

            package_installation #Comprueba los paquetes que son necesarios y, si no, los instala

                #Obtiene el nombre del fichero desde la URL
            fichero=$(basename "$enlace")
                #Almacena en una variable la ruta que tendría el fichero
            ruta_fichero="/opt/$directorio/$fichero"

            #Comprueba si el fichero ya existe
            if [ -f "$ruta_fichero" ]; then
                echo "Error, el fichero que intenta descargar ya existe en ese directorio"
                exit 1
            fi

                #Descarga el archivo en el directorio
            sudo wget -q -P "/opt/$directorio" "$enlace"

                #Comprueba que el archivo descargado existe
            if [ ! -f "$ruta_fichero" ]; then
                echo "Error, no se ha encontrado el archivo descargado $fichero"
                exit 1
            fi

                #Lo descomprime
            if [[ "$fichero" == *.tar.gz ]]; then
                sudo tar -xzf "$ruta_fichero" -C "/opt/$directorio"
            elif [[ "$fichero" == *.tar.bz2 ]]; then
                sudo tar -xjf "$ruta_fichero" -C "/opt/$directorio"
            else
                echo "Archivo descargado, pero no es .tar.gz ni .tar.bz2"
                echo "No se ha podido descomprimir"
                exit 1
            fi

            last_error_control

        else
            echo "Error, el directorio no existe. Créelo primero"
            exit 1
        fi
        ;;
    cerrar)
        if [ -d "/opt/$directorio" ]; then
            nombre_archivo="${destino}_$(date +%Y_%m_%d).tar.gz"
            dir_destino="/usr/local/lib"

                #Crea el archivo en el directorio de destino
            sudo tar -czf "$dir_destino/$nombre_archivo" -C "/opt" "$directorio"

        else
            echo "Error, el directorio $directorio no existe"
            exit 1
        fi
        ;;
    recuperar)
            #Busca la o las copias que haya con ese nombre
        copias=$(find /usr/local/lib -maxdepth 1 -type f -name "$directorio*")

            #Controla la existencia de alguna copia de seguridad
        if [ -z "$copias" ]; then
            echo "Error, no existe ninguna copia de seguridad sobre esa configuración"
            exit 1
        else
                #Comprueba si existe el directorio donde se va a recuperar
            if [ ! -d "/opt/$directorio" ]; then
                echo "Error, no existe el directorio $directorio y no se podrá guardar la copia de seguridad allí"
                echo "Creelo usando el USO 1 de este script"
                exit 1
            fi

                #Ordena las copias y coge solo la última
            archivo=$(echo $copias | tr " " "\n" | sort -nr | head -1)

                #Borra el contenido del directorio de destino
            destino="/opt/$directorio"
            sudo rm -r $destino/*

                #Extrae el contenido en el directorio de destino
            sudo tar -xzf "$archivo" -C "/opt/$directorio"

            last_error_control
            ;;
    *)
        echo "Error, la acción que ha introducido no ha sido encontrada"
        ;;
esac