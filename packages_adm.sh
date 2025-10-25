#! /bin/bash

#----Author:LauraLinares-----
#---------Version:1.0--------
#---Script:packages_adm.sh---
#--Uso 1. script.sh nuevaconfig nombre_de_la_nueva_configuracion
#---------por defecto usará el directorio /opt
#---------creará un directorio dentro del directorio por defecto

#--Uso 2. script.sh descargar directorio_donde_descargar enlace
#---------descargará y descomprimirá el enlace en el directorio

#--Uso 3. script.sh cerrar nombre_de_la_configuracion
#---------comprimirá lo existente en el directorio especificado y
#---------guadará dicho paquete comprimido en /opt/lib haciendo una
#---------copia de seguridad

#--Uso 4. script.sh recuperar nombre_de_la_configuracion
#---------desempaquetará la copia de seguridad especificada y la
#---------copiará en el directorio /opt, eliminando lo que hubiese

#--Declaración de variables--



#--Declaración de funciones--


#------Inicio del script-----

    #Controla que se pase mínimo 1 parámetro
if [ $# -eq 0 ]; then
    echo "Error, no se ha pasado ningún parámetro"
    echo "Uso de $0: <script><acción><opciones>"
    exit 1
fi

#--Uso 1. script.sh nuevaconfig nombre_de_la_nueva_configuracion--
if [ "$1" = "nuevaconfig" ]; then
        #Controla que se hayan pasado los parámetros necesarios
    if [ $# -ne 2 ]; then
        echo "Error, no se han pasado los parámetros determinados"
        echo "Uso 1 de $0: <script> <nuevaconfig> <nombre_de_la_nueva_configuracion>"
        exit 1
    fi
    directorio="$2"

        #Comprueba si el directorio existe
    comando=$(find /opt -maxdepth 1 -type d -name "$directorio")
    if [ $comando ]; then
        echo "Error, el directorio \"$directorio\" que intenta crear, ya existe"
        exit 1
    fi

        #Crea el directorio
    sudo mkdir /opt/$directorio

        #Controla que el último proceso haya sido exitoso
    if [ $? -eq 0 ]; then
        echo "El directorio \"$directorio\" se ha creado en /opt"
    else
        echo "Ha ocurrido un error creando el directorio"
        exit 1
    fi

#--Uso 2. script.sh descargar directorio_donde_descargar enlace--
elif [ "$1" = "descargar" ]; then
        #Controla que se hayan pasado los parámetros necesarios
    if [ $# -ne 3 ]; then
        echo "Error, no se han pasado los parámetros determinados"
        echo "Uso 2 de $0: <script> <descargar> <directorio_donde_descargar> <enlace>"
        exit 1
    fi
    directorio="$2"
    enlace="$3"

        #Comprueba si existe el directorio donde desea descargar
    comando=$(find /opt -maxdepth 1 -type d -name "$directorio")
    if [ $comando ]; then
            #Comprueba que los paquetes necesarios estén instalados
        for i in wget gzip bzip2; do
            if ! command -V "$i" >/dev/null 2>&1; then
                echo "Instalando $i"
                sudo apt-get update -qq
                sudo apt-get install -y -qq "$i"
            fi
        done

            #Descarga el archivo en el directorio adecuado
        sudo wget -q -P "/opt/$directorio" "$enlace"
            #Saca el nombre del archivo, primero buscándolo, luego cogiendo solo el nombre base
        x=$(find "/opt/$directorio" -maxdepth 1 -type f -name "*.tar.*" | head -n 1)
        archivo=$(basename "$x")      

            #Lo descomprime
        if [[ "$archivo" == *.tar.gz ]]; then
            sudo tar -xzf "/opt/$directorio/$archivo" -C "/opt/$directorio"
        elif [[ "$archivo" == *.tar.bz2 ]]; then
            sudo tar -xjf "/opt/$directorio/$archivo" -C "/opt/$directorio"
        else
            echo "Archivo descargado, pero no es .tar.gz ni .tar.bz2"
            echo "No se ha procedido a descomprimirlo"
        fi
            #Controla que el último proceso haya sido exitoso
        if [ $? -eq 0 ]; then
            echo "El archivo ha sido descargado y descomprimido con éxito"
        fi
    else
        echo "Error, el directorio no existe. Créelo primero"
        echo "Para crearlo puede usar el USO 1 de este script"
        exit 1
    fi
fi