#!/bin/bash

# Función para obtener entrada del usuario con un valor por defecto y validar opciones
prompt() {
    local input
    read -p "$1 [$2]: " input
    input=${input:-$2}
    if [[ " $3 " == *" $input "* ]]; then
        echo "$input"
    else
        echo "Opción no válida: $input"
        exit 1
    fi
}

# Función para obtener entrada del usuario con una URL válida
prompt_url() {
    local input
    read -p "$1 [$2]: " input
    input=${input:-$2}
    if [[ "$input" =~ ^https:// ]]; then
        echo "$input"
    else
        echo "Por favor, ingrese una URL válida que comience con https://"
        exit 1
    fi
}

# Función para obtener entrada del usuario con un valor por defecto y validar texto
prompt_text() {
    read -p "$1 [$2]: " input
    echo "${input:-$2}"
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

# Función para obtener la cantidad de memoria RAM del sistema (en MB)
get_free_memory() {
    free -m | awk '/^Mem:/{print $2}'
}

# Función para obtener la memoria máxima permitida (en MB, 80% del total)
get_max_memory() {
    local total_mem
    total_mem=$(get_free_memory)
    echo $((total_mem * 80 / 100))
}

# Función para obtener la memoria mínima permitida (en MB, 512MB)
get_min_memory() {
    echo 512
}

# Función para solicitar la cantidad de memoria con validación
prompt_memory() {
    local input
    local min_mem
    local max_mem
    min_mem=$(get_min_memory)
    max_mem=$(get_max_memory)

    while true; do
        read -p "$1 [Min: ${min_mem}M, Max: ${max_mem}M, ej. 512M, 2G]: " input
        if [[ "$input" =~ ^[0-9]+[MG]$ ]]; then
            local unit=${input: -1}
            local value=${input%$unit}
            if [[ $unit == "M" && $value -ge $min_mem && $value -le $max_mem ]]; then
                echo "$input"
                return
            elif [[ $unit == "G" ]]; then
                value=$((value * 1024))
                if [[ $value -ge $min_mem && $value -le $max_mem ]]; then
                    echo "${input}"
                    return
                fi
            fi
        fi
        echo "Opción no válida: $input"
        exit 1
    done
}

# Segunda comprobación del valor de la memoria
check_memory() {
    local input=$1
    local min_mem
    local max_mem
    min_mem=$(get_min_memory)
    max_mem=$(get_max_memory)

    if [[ "$input" =~ ^[0-9]+[MG]$ ]]; then
        local unit=${input: -1}
        local value=${input%$unit}
        if [[ $unit == "M" && $value -ge $min_mem && $value -le $max_mem ]]; then
            return 0
        elif [[ $unit == "G" ]]; then
            value=$((value * 1024))
            if [[ $value -ge $min_mem && $value -le $max_mem ]]; then
                return 0
            fi
        fi
    fi
    echo "Opción no válida: $input. La memoria debe estar entre ${min_mem}M y ${max_mem}M."
    exit 1
}

# Actualiza e instala las dependencias necesarias
sudo apt-get update && \
sudo apt-get install -y openjdk-21-jre-headless firewalld screen unzip

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
    8) OTRA (Ingresa una URL personalizada)
    9) Serverpack (Ingresa una URL para descargar un paquete de servidor)" "1.21" "1.21 1.20.6 1.20.4 1.20.3 1.20.2 1.20.1 1.20 OTRA Serverpack")

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
    Serverpack)
        serverpack_url=$(prompt_url "Ingresa la URL del paquete de servidor" "https://")
        mkdir -p ~/minecraft_server && cd ~/minecraft_server
        wget "$serverpack_url" -O serverpack.zip
        unzip serverpack.zip
        rm serverpack.zip

        # Aceptar el EULA
        echo "eula=true" > eula.txt

        # Solicitar memoria y modificar JAVA_ARGS en variables.txt
        memory=$(prompt_memory "Selecciona la cantidad de memoria para el servidor de Minecraft. Introduce un valor como 512M o 2G")
        check_memory "$memory"
        sed -i "s/^JAVA_ARGS=.*/JAVA_ARGS=\"-Xmx${memory} -Xms${memory}\"/" variables.txt

        # Solicitar configuración del archivo server.properties
        difficulty=$(prompt "Selecciona la dificultad del servidor (peaceful, easy, normal, hard)" "normal" "peaceful easy normal hard")
        gamemode=$(prompt "Selecciona el modo de juego del servidor (survival, creative, adventure, spectator)" "survival" "survival creative adventure spectator")
        level_seed=$(prompt_text "Ingresa la semilla del mundo (opcional)" "")
        max_players=$(prompt_number "Ingresa el número máximo de jugadores permitidos en el servidor" "20")
        pvp=$(prompt "Selecciona si el PvP está activado en el servidor (true, false)" "true" "true false")
        online_mode=$(prompt "Selecciona el modo online del servidor (true para solo premium, false para no premium)" "true" "true false")
        motd=$(prompt_text "Ingresa el mensaje del día para mostrar en el servidor" "Better MC [FORGE] 1.20.1")

        # Modificar el archivo server.properties
        sed -i "s/^difficulty=.*/difficulty=$difficulty/" server.properties
        sed -i "s/^gamemode=.*/gamemode=$gamemode/" server.properties
        sed -i "s/^level-seed=.*/level-seed=$level_seed/" server.properties
        sed -i "s/^max-players=.*/max-players=$max_players/" server.properties
        sed -i "s/^motd=.*/motd=$motd/" server.properties
        sed -i "s/^online-mode=.*/online-mode=$online_mode/" server.properties
        sed -i "s/^pvp=.*/pvp=$pvp/" server.properties

        # Ejecuta el script start.sh si existe
        if [ -f start.sh ]; then
            bash start.sh
        else
            echo "No se encontró el archivo start.sh en el paquete del servidor."
            exit 1
        fi
        exit 0
        ;;
    OTRA)
        server_url=$(prompt_url "Ingresa la URL personalizada del servidor Forge" "https://maven.minecraftforge.net/net/minecraftforge/forge")
        ;;
    *)
        echo "Opción no válida. Seleccione una de las opciones listadas o ingrese OTRA para una URL personalizada."
        exit 1
        ;;
esac

# Configura la memoria del servidor con entrada del usuario
memory=$(prompt_memory "Selecciona la cantidad de memoria para el servidor de Minecraft. Introduce un valor como 512M o 2G")

# Segunda comprobación del valor de la memoria
check_memory "$memory"

# Crea el directorio del servidor y descarga el instalador de Forge
mkdir -p ~/minecraft_server && cd ~/minecraft_server
wget "$server_url" -O server-installer.jar

# Ejecuta el instalador de Forge
java -jar server-installer.jar --installServer
server_jar="forge-$(basename "$server_url" | sed 's/-installer.jar/.jar/')"

# Editar el archivo user_jvm_args.txt para configurar la RAM
sed -i "s/^#* -Xmx.*/-Xmx${memory}/" user_jvm_args.txt

# Crea y acepta el archivo eula.txt
echo "eula=true" > eula.txt

# Solicitar configuración del archivo server.properties
difficulty=$(prompt "Selecciona la dificultad del servidor (peaceful, easy, normal, hard)" "normal" "peaceful easy normal hard")
gamemode=$(prompt "Selecciona el modo de juego del servidor (survival, creative, adventure, spectator)" "survival" "survival creative adventure spectator")
level_seed=$(prompt_text "Ingresa la semilla del mundo (opcional)" "")
max_players=$(prompt_number "Ingresa el número máximo de jugadores permitidos en el servidor" "20")
pvp=$(prompt "Selecciona si el PvP está activado en el servidor (true, false)" "true" "true false")
online_mode=$(prompt "Selecciona el modo online del servidor (true para solo premium, false para no premium)" "true" "true false")
motd=$(prompt_text "Ingresa el mensaje del día para mostrar en el servidor" "Better MC [FORGE] 1.20.1")

# Modificar el archivo server.properties
sed -i "s/^difficulty=.*/difficulty=$difficulty/" server.properties
sed -i "s/^gamemode=.*/gamemode=$gamemode/" server.properties
sed -i "s/^level-seed=.*/level-seed=$level_seed/" server.properties
sed -i "s/^max-players=.*/max-players=$max_players/" server.properties
sed -i "s/^motd=.*/motd=$motd/" server.properties
sed -i "s/^online-mode=.*/online-mode=$online_mode/" server.properties
sed -i "s/^pvp=.*/pvp=$pvp/" server.properties

# Ejecuta el script ./run.sh
bash ./run.sh

# Mensaje final
echo "Servidor de Minecraft Forge configurado y ejecutándose."
