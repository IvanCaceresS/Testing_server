#!/bin/bash

# Función para obtener entrada del usuario con un valor por defecto y validar opciones
prompt() {
    local input
    while true; do
        read -p "$1 [$2]: " input
        input=${input:-$2}
        if [[ " $3 " == *" $input "* ]]; then
            echo "$input"
            return
        else
            echo "Opción no válida. Las opciones válidas son: $3"
        fi
    done
}

# Función para obtener entrada del usuario con un valor por defecto y validar números
prompt_number() {
    local input
    while true; do
        read -p "$1 [$2]: " input
        input=${input:-$2}
        if [[ "$input" =~ ^[0-9]+$ ]]; then
            echo "$input"
            return
        else
            echo "Por favor, ingrese un número válido."
        fi
    done
}

# Función para obtener entrada del usuario con un valor por defecto
prompt_text() {
    read -p "$1 [$2]: " input
    echo "${input:-$2}"
}

# Función para obtener la URL del servidor Forge
prompt_forge_url() {
    local input
    while true; do
        read -p "$1 [Ver opciones de arriba o OTRA]: " input
        if [[ "$input" =~ ^(1.21|1.20\.6|1.20\.4|1.20\.3|1.20\.2|1.20\.1|1.20|OTRA)$ ]]; then
            case $input in
                1.21)
                    server_url="https://maven.minecraftforge.net/net/minecraftforge/forge/1.21-51.0.24/forge-1.21-51.0.24-installer.jar"
                    ;;
                1.20.6)
                    server_url="https://maven.minecraftforge.net/net/minecraftforge/forge/1.20.6-50.1.0/forge-1.20.6-50.1.0-installer.jar"
                    ;;
                1.20.4)
                    server_url="https://maven.minecraftforge.net/net/minecraftforge/forge/1.20.4-49.1.0/forge-1.20.4-49.1.0-installer.jar"
                    ;;
                1.20.3)
                    server_url="https://maven.minecraftforge.net/net/minecraftforge/forge/1.20.3-49.0.2/forge-1.20.3-49.0.2-installer.jar"
                    ;;
                1.20.2)
                    server_url="https://maven.minecraftforge.net/net/minecraftforge/forge/1.20.2-48.1.0/forge-1.20.2-48.1.0-installer.jar"
                    ;;
                1.20.1)
                    server_url="https://maven.minecraftforge.net/net/minecraftforge/forge/1.20.1-47.3.0/forge-1.20.1-47.3.0-installer.jar"
                    ;;
                1.20)
                    server_url="https://maven.minecraftforge.net/net/minecraftforge/forge/1.20-46.0.14/forge-1.20-46.0.14-installer.jar"
                    ;;
                OTRA)
                    read -p "Ingresa la URL personalizada del servidor Forge: " server_url
                    ;;
            esac
            if [[ "$server_url" =~ ^https://maven.minecraftforge.net ]]; then
                echo "$server_url"
                return
            else
                echo "URL no válida. Debe empezar con https://maven.minecraftforge.net"
            fi
        else
            echo "Opción no válida. Seleccione una de las opciones listadas o ingrese OTRA para una URL personalizada."
        fi
    done
}

# Actualiza e instala las dependencias necesarias
sudo apt-get update && \
sudo apt-get install -y openjdk-21-jre-headless firewalld screen

# Configura el firewall
sudo firewall-cmd --permanent --zone=public --add-port=25565/tcp
sudo firewall-cmd --permanent --zone=public --add-port=25565/udp
sudo firewall-cmd --reload


# Crea el directorio del servidor y descarga el instalador de Forge
mkdir -p ~/minecraft_server && cd ~/minecraft_server
server_url=$(prompt_forge_url "Elige la versión de Forge para instalar" "1.21 1.20.6 1.20.4 1.20.3 1.20.2 1.20.1 1.20 OTRA")

# Descarga y ejecuta el instalador de Forge
wget $server_url -O server-installer.jar
java -jar server-installer.jar --installServer
server_jar="forge-$(echo $version | cut -d- -f1).0.0.jar"  # Ajusta el nombre según la versión

# Editar el archivo user_jvm_args.txt para configurar la RAM
sed -i 's/# -Xmx4G/-Xmx'$memory'/' user_jvm_args.txt

# Crea y acepta el archivo eula.txt
echo "eula=true" > eula.txt

# Ejecuta el script ./run.sh
bash ./run.sh

# Mensaje final
echo "Servidor de Minecraft Forge configurado y ejecutándose."