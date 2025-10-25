#! /bin/bash

#----Author:LauraLinares-----
#---------Version:1.0--------
#---Script:packages_adm.sh---
#--Uso 1. script.sh nuevaconfig nombre_de_la_nueva_configuracion
#---------por defecto usará el directorio /opt
#---------creará un directorio dentro del directorio por defecto

#--Uso 2. script.sh descargar enlace directorio_donde_se_descargará
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

#--Uso 1--
if [ "$1" = "nuevaconfig" ]; then
        if [ $# -eq 2 ]; then
                echo "Error, no se han pasado los parámetros específicos"
                echo "Uso 1 de $0: <script> <nuevaconfig> <nombre_de_la_nueva_configuracion>"
                exit 1
        fi
        directorio=$2
        if 


fi
