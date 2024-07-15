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

# Función para obtener entrada del usuario con una URL válida
prompt_url() {
    local input
    while true; do
        read -p "$1 [$2]: " input
        input=${input:-$2}
        if [[ "$input" =~ ^https:// ]]; then
            echo "$input"
            return
        else
            echo "Por favor, ingrese una URL válida que comience con https://"
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

# Selección de la versión del servidor Forge
version=$(prompt "Elige la versión de Forge para instalar:
    1) 1.21
    2) 1.20.6
    3) 1.20.4
    4) 1.20.3
    5) 1.20.2
    6) 1.20.1
    7) 1.20
    8) OTRA (Ingresa una URL personalizada)" "1.21" "1.21 1.20.6 1.20.4 1.20.3 1.20.2 1.20.1 1.20 OTRA")

case $version in
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
        server_url=$(prompt_url "Ingresa la URL personalizada del servidor Forge" "https://maven.minecraftforge.net")
        ;;
esac

# Crea el directorio del servidor y descarga el instalador de Forge
mkdir -p ~/minecraft_server && cd ~/minecraft_server
wget "$server_url" -O server-installer.jar

# Ejecuta el instalador de Forge
java -jar server-installer.jar --installServer
server_jar="forge-$(basename "$server_url" | sed 's/-installer.jar/.jar/')"

# Función para obtener la cantidad de memoria RAM del sistema (en MB)
get_free_memory() {
    free -m | awk '/^Mem:/{print $2}'
}

# Función para obtener la memoria máxima permitida (en MB, 80% del total)
get_max_memory() {
    local total_mem=$(get_free_memory)
    echo $((total_mem * 80 / 100))
}

# Configura la memoria del servidor con entrada del usuario
max_mem=$(get_max_memory)
memory=$(prompt "Selecciona la cantidad de memoria para el servidor de Minecraft. Introduce un valor como 512M o 2G" "2G" "512M 1G 1.5G 2G 3G 4G 6G 8G")

# Editar el archivo user_jvm_args.txt para configurar la RAM
sed -i "s/^#* -Xmx.*/-Xmx${memory}/" user_jvm_args.txt

# Crea y acepta el archivo eula.txt
echo "eula=true" > eula.txt

# Ejecuta el script ./run.sh
bash ./run.sh

# Mensaje final
echo "Servidor de Minecraft Forge configurado y ejecutándose."
