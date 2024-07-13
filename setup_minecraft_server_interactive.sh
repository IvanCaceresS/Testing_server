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

# Función para obtener entrada del usuario con validación de memoria
prompt_memory() {
    local input
    local total_mem
    local max_mem
    total_mem=$(free -m | awk '/^Mem:/{print $2}')
    max_mem=$((total_mem * 80 / 100))
    
    while true; do
        read -p "$1 [$2]: " input
        input=${input:-$2}
        if [[ "$input" =~ ^[0-9]+[MG]$ ]]; then
            if [[ "$input" =~ M$ ]]; then
                mem_value=${input%M}
                if [[ "$mem_value" -ge 512 && "$mem_value" -le "$max_mem" ]]; then
                    echo "$input"
                    return
                fi
            elif [[ "$input" =~ G$ ]]; then
                mem_value=$((${input%G} * 1024))
                if [[ "$mem_value" -ge 512 && "$mem_value" -le "$max_mem" ]]; then
                    echo "$input"
                    return
                fi
            fi
        fi
        echo "Por favor, ingrese un valor válido (ej. 512M, 2G). El mínimo es 512M y el máximo es ${max_mem}M."
    done
}

# Función para obtener la URL del servidor
prompt_url() {
    local input
    while true; do
        read -p "$1 [$2]: " input
        input=${input:-$2}
        if [[ "$input" =~ ^https://launcher.mojang.com ]]; then
            echo "$input"
            return
        else
            echo "Por favor, ingrese una URL válida que comience con https://launcher.mojang.com"
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

# Selección de la versión del servidor
version=$(prompt "Elige la versión del servidor (1.21, 1.20.6, 1.20.5, 1.20.4, 1.20.3, 1.20.2, 1.20.1, 1.20, OTRA) o ingresa otra URL personalizada" "1.21" "1.21 1.20.6 1.20.5 1.20.4 1.20.3 1.20.2 1.20.1 1.20 OTRA")
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
esac


# Crea el directorio del servidor y descarga el servidor de Minecraft
mkdir ~/minecraft_server && \
cd ~/minecraft_server
wget $server_url -O server.jar

# Configura la memoria del servidor con entrada del usuario
memory=$(prompt_memory "Elige la cantidad de memoria para el servidor (ej. 512M, 2G)" "18G")

# Crea y acepta el archivo eula.txt
echo "eula=true" > eula.txt

# Configura el servidor con entrada del usuario
difficulty=$(prompt "Elige la dificultad (peaceful, easy, normal, hard)" "easy" "peaceful easy normal hard")
gamemode=$(prompt "Elige el modo de juego (survival, creative, adventure, spectator)" "survival" "survival creative adventure spectator")
level_seed=$(prompt_text "Elige la semilla del mundo" "")
max_players=$(prompt_number "Elige el número máximo de jugadores" "20")
pvp=$(prompt "Elige si el PvP está activado (true, false)" "true" "true false")
online_mode=$(prompt "Elige el modo online (true para solo premium, false para no premium)" "true" "true false")
motd=$(prompt_text "Elige el mensaje del día (motd)" "A Minecraft Server")

# Crea el archivo server.properties
cat > server.properties <<EOL
#Minecraft server properties
#$(date)
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

# Inicia el servidor con screen
screen -dmS minecraft_server java -Xmx$memory -Xms$memory -jar server.jar nogui

echo "Servidor de Minecraft configurado y ejecutándose en screen."
