#!/bin/bash

# Función para obtener entrada del usuario con un valor por defecto y validar opciones
prompt() {
    local prompt_message="$1 [$2]: "
    local default_value="$2"
    local valid_options="$3"
    local input

    while true; do
        read -p "$prompt_message" input
        input=${input:-$default_value}

        if [[ " $valid_options " == *" $input "* ]]; then
            echo "$input"
            return
        else
            echo "Opción no válida. Las opciones válidas son: $valid_options"
        fi
    done
}

# Función para obtener la URL del servidor Forge
prompt_forge_url() {
    local input
    local server_url
    local valid_options="1.21 1.20.6 1.20.4 1.20.3 1.20.2 1.20.1 1.20 OTRA"

    while true; do
        echo "Versiones disponibles de Forge:"
        echo "1.21"
        echo "1.20.6"
        echo "1.20.4"
        echo "1.20.3"
        echo "1.20.2"
        echo "1.20.1"
        echo "1.20"
        echo "OTRA (Ingresa una URL personalizada)"

        read -p "Elige la versión de Forge para instalar [Ver opciones de arriba o OTRA]: " input

        if [[ " $valid_options " == *" $input "* ]]; then
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
                    if [[ ! "$server_url" =~ ^https:// ]]; then
                        echo "Error: La URL debe comenzar con 'https://'."
                        continue
                    elif [[ ! "$server_url" =~ ^https://maven.minecraftforge.net ]]; then
                        echo "Error: La URL no es válida para descargar el instalador."
                        continue
                    else
                        echo "$server_url"
                        return
                    fi
                    ;;
            esac

            if [[ -n "$server_url" ]]; then
                echo "URL de descarga seleccionada: $server_url"
                return
            fi
        else
            echo "Opción no válida. Seleccione una de las opciones listadas o ingrese OTRA para una URL personalizada."
        fi
    done
}

# Función para obtener la cantidad de memoria RAM del sistema (en MB)
get_free_memory() {
    free -m | awk '/^Mem:/{print $2}'
}

# Función para obtener la memoria máxima permitida (en MB, 80% del total)
get_max_memory() {
    local total_mem=$(get_free_memory)
    echo $((total_mem * 80 / 100))
}

# Función para obtener la memoria mínima permitida (en MB, 512MB)
get_min_memory() {
    echo 512
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
server_url=$(prompt_forge_url)

# Verificar la URL
echo "URL de descarga seleccionada: $server_url"

# Descarga y ejecuta el instalador de Forge
while true; do
    if [[ "$server_url" =~ ^https:// ]]; then
        wget "$server_url" -O server-installer.jar
        if [ $? -ne 0 ]; then
            echo "Error: No se pudo descargar el instalador desde la URL proporcionada."
            server_url=$(prompt_forge_url)
        else
            break
        fi
    else
        echo "Error: URL no válida para descargar el instalador."
        server_url=$(prompt_forge_url)
    fi
done

java -jar server-installer.jar --installServer
server_jar="forge-$(basename "$server_url" | cut -d- -f2-4)-installer.jar"

# Obtener la memoria máxima y mínima permitida
max_mem=$(get_max_memory)
min_mem=$(get_min_memory)

# Configura la memoria del servidor con entrada del usuario
memory=$(prompt "Selecciona la cantidad de memoria para el servidor de Minecraft. Introduce un valor como 512M o 2G" "2G" "512M 1G 1.5G 2G 3G 4G 6G 8G")

# Editar el archivo user_jvm_args.txt para configurar la RAM
sed -i "s/^#* -Xmx.*/-Xmx${memory}/" user_jvm_args.txt

# Crea y acepta el archivo eula.txt
echo "eula=true" > eula.txt

# Ejecuta el script ./run.sh
bash ./run.sh

# Mensaje final
echo "Servidor de Minecraft Forge configurado y ejecutándose."
