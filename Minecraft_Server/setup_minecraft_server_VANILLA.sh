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
    if [[ "$input" =~ ^https://launcher.mojang.com ]]; then
        echo "$input"
    else
        echo "Por favor, ingrese una URL válida que comience con https://launcher.mojang.com"
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
        echo "Opción no válida: $input. La memoria debe estar entre ${min_mem}M y ${max_mem}M."
        exit 1
    done
}

# Función para configurar el firewall
configure_firewall() {
    sudo apt-get update && \
    sudo apt-get install -y openjdk-21-jre-headless firewalld screen
    sudo firewall-cmd --permanent --zone=public --add-port=25565/tcp
    sudo firewall-cmd --permanent --zone=public --add-port=25565/udp
    sudo firewall-cmd --reload
}

# Función para seleccionar la versión del servidor
select_server_version() {
    version=$(prompt "Elige la versión del servidor Minecraft:
        1) 1.21
        2) 1.20.6
        3) 1.20.5
        4) 1.20.4
        5) 1.20.3
        6) 1.20.2
        7) 1.20.1
        8) 1.20
        9) OTRA (Ingresa una URL personalizada)" "1.21" "1.21 1.20.6 1.20.5 1.20.4 1.20.3 1.20.2 1.20.1 1.20 OTRA")

    case $version in
        1.21)
            server_url="https://launcher.mojang.com/v1/objects/450698d1863ab5180c25d7c804ef0fe6369dd1ba/server.jar"
            ;;
        1.20.6)
            server_url="https://launcher.mojang.com/v1/objects/145ff0858209bcfc164859ba735d4199aafa1eea/server.jar"
            ;;
        1.20.5)
            server_url="https://launcher.mojang.com/v1/objects/79493072f65e17243fd36a699c9a96b4381feb91/server.jar"
            ;;
        1.20.4)
            server_url="https://launcher.mojang.com/v1/objects/8dd1a28015f51b1803213892b50b7b4fc76e594d/server.jar"
            ;;
        1.20.3)
            server_url="https://launcher.mojang.com/v1/objects/4fb536bfd4a83d61cdbaf684b8d311e66e7d4c49/server.jar"
            ;;
        1.20.2)
            server_url="https://launcher.mojang.com/v1/objects/5b868151bd02b41319f54c8d4061b8cae84e665c/server.jar"
            ;;
        1.20.1)
            server_url="https://launcher.mojang.com/v1/objects/84194a2f286ef7c14ed7ce0090dba59902951553/server.jar"
            ;;
        1.20)
            server_url="https://launcher.mojang.com/v1/objects/15c777e2cfe0556eef19aab534b186c0c6f277e1/server.jar"
            ;;
        "OTRA")
            server_url=$(prompt_url "Ingresa la URL personalizada del servidor" "https://launcher.mojang.com/v1/objects/84194a2f286ef7c14ed7ce0090dba59902951553/server.jar")
            ;;
        *)
            echo "Opción no válida. Seleccione una de las opciones listadas o ingrese OTRA para una URL personalizada."
            exit 1
            ;;
    esac
}

# Función para configurar el archivo server.properties
configure_server_properties() {
    difficulty=$(prompt "Selecciona la dificultad del servidor (peaceful, easy, normal, hard)" "normal" "peaceful easy normal hard")
    gamemode=$(prompt "Selecciona el modo de juego del servidor (survival, creative, adventure, spectator)" "survival" "survival creative adventure spectator")
    level_seed=$(prompt_text "Ingresa la semilla del mundo (opcional)" "")
    max_players=$(prompt_number "Ingresa el número máximo de jugadores permitidos en el servidor" "20")
    pvp=$(prompt "Selecciona si el PvP está activado en el servidor (true, false)" "true" "true false")
    online_mode=$(prompt "Selecciona el modo online del servidor (true para solo premium, false para no premium)" "true" "true false")
    motd=$(prompt_text "Ingresa el mensaje del día para mostrar en el servidor" "A Minecraft Server")

    cat > server.properties <<EOL
# Minecraft server properties
# $(date)
enable-jmx-monitoring=false
rcon.port=25575
level-seed=$level_seed
gamemode=$gamemode
enable-command-block=false
enable-query=false
generator-settings={}
enforce-secure-profile=true
level-name=world
motd=$motd
query.port=25565
pvp=$pvp
generate-structures=true
max-chained-neighbor-updates=1000000
difficulty=$difficulty
network-compression-threshold=256
max-tick-time=60000
require-resource-pack=false
use-native-transport=true
max-players=$max_players
online-mode=$online_mode
enable-status=true
allow-flight=false
initial-disabled-packs=
broadcast-rcon-to-ops=true
view-distance=10
server-ip=
resource-pack-prompt=
allow-nether=true
server-port=25565
enable-rcon=false
sync-chunk-writes=true
op-permission-level=4
prevent-proxy-connections=false
hide-online-players=false
resource-pack=
entity-broadcast-range-percentage=100
simulation-distance=10
rcon.password=
player-idle-timeout=0
force-gamemode=false
rate-limit=0
hardcore=false
white-list=false
broadcast-console-to-ops=true
spawn-npcs=true
spawn-animals=true
log-ips=true
function-permission-level=2
initial-enabled-packs=vanilla
level-type=minecraft:normal
text-filtering-config=
spawn-monsters=true
enforce-whitelist=false
spawn-protection=16
resource-pack-sha1=
max-world-size=29999984
EOL
}

# Función principal
main() {
    configure_firewall
    select_server_version

    mkdir -p ~/minecraft_server && cd ~/minecraft_server
    wget $server_url -O server.jar

    max_mem=$(get_max_memory)
    memory=$(prompt_memory "Selecciona la cantidad de memoria para el servidor de Minecraft. Introduce un valor como 512M o 2G (máximo recomendado: ${max_mem}M)" "${max_mem}M")

    echo "eula=true" > eula.txt

    configure_server_properties

    screen -dmS minecraft_server java -Xmx$memory -Xms$memory -jar server.jar nogui

    echo "Servidor de Minecraft configurado y ejecutándose en screen."
    echo "Para ver la consola del servidor, usa: screen -r minecraft_server"
    echo "Para salir de la consola pero dejar el servidor ejecutándose, presiona Ctrl + A seguido de D."
}

# Ejecutar función principal
main