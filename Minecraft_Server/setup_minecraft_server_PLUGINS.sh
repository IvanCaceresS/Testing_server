#!/bin/bash

# Función para actualizar e instalar los paquetes necesarios
install_dependencies() {
    sudo apt update
    sudo apt upgrade -y
    sudo apt install -y wget screen
}

# Función para instalar la versión correcta de Java
install_java() {
    local java_version=$1
    case $java_version in
        8) sudo apt install -y openjdk-8-jdk ;;
        11) sudo apt install -y openjdk-11-jdk ;;
        16) sudo apt install -y openjdk-16-jdk ;;
        21) sudo apt install -y openjdk-21-jdk ;;
    esac
}

# Función para mostrar el menú
show_menu() {
    echo "Seleccione la versión de PaperMC que desea instalar:"
    echo "1) 1.20.4"
    echo "2) 1.20.2"
    echo "3) 1.20.1"
    echo "4) 1.20"
    echo "5) 1.19.4"
    echo "6) 1.19.3"
    echo "7) 1.19.2"
    echo "8) 1.19.1"
    echo "9) 1.19"
    echo "10) 1.18.2"
    echo "11) 1.18.1"
    echo "12) 1.18"
    echo "13) 1.17.1"
    echo "14) 1.17"
    echo "15) 1.16.5"
    echo "16) 1.16.4"
    echo "17) 1.16.3"
    echo "18) 1.16.2"
    echo "19) 1.16.1"
    echo "20) 1.15.2"
    echo "21) 1.14.4"
    echo "22) 1.13.2"
    echo "23) 1.12.2"
    echo "24) 1.11.2"
    echo "25) 1.10.2"
    echo "26) 1.9.4"
    echo "27) 1.8.8"
    echo "0) Salir"
}

# Función para configurar server.properties
configure_server_properties() {
    local properties_file=$1

    # Valores por defecto
    local level_seed=""
    local gamemode="survival"
    local level_name="world"
    local motd="A Minecraft Server"
    local pvp="true"
    local difficulty="easy"
    local max_players="20"
    local online_mode="true"

    # Menú de configuración
    echo "Configuración de server.properties"
    read -p "Ingrese el seed del mundo (level-seed) [$level_seed]: " input
    level_seed=${input:-$level_seed}
    read -p "Ingrese el modo de juego (gamemode) [survival/creative/adventure/spectator] [$gamemode]: " input
    gamemode=${input:-$gamemode}
    read -p "Ingrese el nombre del mundo (level-name) [$level_name]: " input
    level_name=${input:-$level_name}
    read -p "Ingrese el mensaje del día (motd) [$motd]: " input
    motd=${input:-$motd}
    read -p "Habilitar PvP (pvp) [true/false] [$pvp]: " input
    pvp=${input:-$pvp}
    read -p "Ingrese la dificultad (difficulty) [peaceful/easy/normal/hard] [$difficulty]: " input
    difficulty=${input:-$difficulty}
    read -p "Ingrese el número máximo de jugadores (max-players) [$max_players]: " input
    max_players=${input:-$max_players}
    read -p "Habilitar modo en línea (online-mode) [true/false] [$online_mode]: " input
    online_mode=${input:-$online_mode}

    # Crear el archivo server.properties
    echo "#Minecraft server properties" > "$properties_file"
    echo "#$(date)" >> "$properties_file"
    cat <<EOL >> "$properties_file"
enable-jmx-monitoring=false
rcon.port=25575
level-seed=$level_seed
gamemode=$gamemode
enable-command-block=false
enable-query=false
generator-settings={}
enforce-secure-profile=true
level-name=$level_name
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

# Función para descargar plugins
download_plugins() {
    local plugins_dir=$1
    mkdir -p "$plugins_dir"
    chmod 775 "$plugins_dir"
    
    declare -A plugins
    plugins=(
        ["GUI_Admin_Tools"]="https://www.spigotmc.org/resources/1-16-1-20-4-%E2%9B%8F%EF%B8%8F-gui-admin-tools-free-%E2%9B%8F%EF%B8%8F.108689/download?version=540552"
        ["Aurelium_Skills"]="https://www.spigotmc.org/resources/auraskills-formerly-aurelium-skills.81069/download?version=547656"
        ["FartherViewDistance"]="https://www.spigotmc.org/resources/fartherviewdistance-archive.84950/download?version=493052"
        ["StackMob"]="https://www.spigotmc.org/resources/stackmob-enhance-your-servers-performance.29999/download?version=549309"
        ["AngelChest"]="https://www.spigotmc.org/resources/angelchest-free.60383/download?version=548417"
        ["Chunky"]="https://www.spigotmc.org/resources/chunky.81534/download?version=540132"
        ["Sleep_most"]="https://www.spigotmc.org/resources/sleep-most-1-8-1-21-x-the-most-advanced-sleep-plugin-available-percentage-animations.60623/download?version=549260"
        ["BlockLocker"]="https://www.spigotmc.org/resources/blocklocker.3268/download?version=539045"
        ["Shopkeepers"]="https://www.spigotmc.org/resources/shopkeepers.80756/download?version=547579"
        ["Action_Bar_Health"]="https://www.spigotmc.org/resources/action-bar-health.2661/download?version=502161"
        ["AutoUpdatePlugins"]="https://www.spigotmc.org/resources/autoupdateplugins.109683/download?version=549400"
        ["Extractable_Enchantments"]="https://www.spigotmc.org/resources/extractable-enchantments-remove-enchantments-1-14-1-21.73954/download?version=549724"
        ["DirectionHUD"]="https://www.spigotmc.org/resources/directionhud.111247/download?version=543904"
        ["ExcellentEnchants"]="https://www.spigotmc.org/resources/excellentenchants-%E2%AD%90-75-vanilla-like-enchantments.61693/download?version=548290"
        ["ChestSort"]="https://www.spigotmc.org/resources/chestsort-api.59773/download?version=544875"
        ["LevelledMobs"]="https://github.com/ArcanePlugins/LevelledMobs/releases/download/4.0.6/LevelledMobs-4.0.6.b35.jar"
        ["Dynmap"]="https://cdn.modrinth.com/data/fRQREgAc/versions/QtTWJjW6/Dynmap-3.7-beta-6-spigot.jar"
        ["Fancy_Physics"]="https://www.spigotmc.org/resources/fancy-physics-%E2%9C%A8-1-19-4-1-20-6.110500/download?version=542723"
    )

    read -p "¿Desea instalar todos los plugins? (s/n): " yn
    case $yn in
        [Ss]* )
            for plugin in "${!plugins[@]}"; do
                wget -O "$plugins_dir/${plugin}.jar" "${plugins[$plugin]}"
                echo "$plugin instalado."
            done
            ;;
        [Nn]* )
            echo "No se instalarán plugins."
            ;;
        * )
            echo "Respuesta no válida. No se instalarán plugins."
            ;;
    esac
}


# Función para descargar e instalar la versión seleccionada
install_papermc() {
    local url=$1
    local version=$2
    local java_version=$3

    # Instalar la versión de Java correspondiente
    install_java $java_version

    # Crear directorio para el servidor
    local server_dir=~/papermc/$version
    mkdir -p "$server_dir"

    # Descargar el archivo
    wget -O "$server_dir/server.jar" $url

    # Crear y aceptar el eula.txt
    echo "eula=true" > "$server_dir/eula.txt"

    # Configurar server.properties
    configure_server_properties "$server_dir/server.properties"

    # Crear carpeta plugins y descargar plugins
    download_plugins "$server_dir/plugins"

    # Solicitar la cantidad de RAM
    local total_mem=$(free -m | awk '/^Mem:/{print $2}')
    local max_mem=$(($total_mem * 80 / 100))

    while true; do
        read -p "Ingrese la cantidad de RAM para el servidor (512M - ${max_mem}M): " ram
        if [[ $ram =~ ^[0-9]+[MG]$ ]]; then
            local ram_value=${ram%[MG]}
            if [[ $ram == *M ]]; then
                [[ $ram_value -ge 512 && $ram_value -le $max_mem ]] && break
            elif [[ $ram == *G ]]; then
                ram_value=$(($ram_value * 1024))
                [[ $ram_value -ge 512 && $ram_value -le $max_mem ]] && break
            fi
        fi
        echo "Cantidad de RAM no válida. Intente nuevamente."
    done

    # Crear el script de inicio
    echo "#!/bin/bash" > "$server_dir/start.sh"
    echo "cd $server_dir" >> "$server_dir/start.sh"
    echo "screen -dmS papermc_server java -Xms$ram -Xmx$ram -jar server.jar --nogui" >> "$server_dir/start.sh"

    # Hacer ejecutable el script de inicio
    chmod +x "$server_dir/start.sh"

    # Iniciar el servidor
    "$server_dir/start.sh"

    echo "PaperMC $version se ha descargado, instalado y el servidor se está ejecutando en una sesión de screen."
    echo "Use 'screen -r papermc_server' para adjuntar la sesión de servidor."

    # Verificar si el servidor se está ejecutando
    sleep 5
    if screen -list | grep -q "papermc_server"; then
        echo "El servidor se ha iniciado correctamente."
    else
        echo "El servidor no se pudo iniciar. Por favor, revise los logs para más detalles."
    fi

    # Preguntar si desea instalar otra versión
    while true; do
        read -p "¿Desea instalar otra versión? (s/n): " yn
        case $yn in
            [Nn]* ) exit;;
            [Ss]* ) return;;
            * ) echo "Por favor responda s o n.";;
        esac
    done
}

# Instalar dependencias al inicio
install_dependencies

while true; do
    show_menu
    read -p "Ingrese una opción: " choice
    case $choice in
        1) install_papermc "https://api.papermc.io/v2/projects/paper/versions/1.20.4/builds/398/downloads/paper-1.20.4-398.jar" "1.20.4" "21";;
        2) install_papermc "https://api.papermc.io/v2/projects/paper/versions/1.20.2/builds/318/downloads/paper-1.20.2-318.jar" "1.20.2" "21";;
        3) install_papermc "https://api.papermc.io/v2/projects/paper/versions/1.20.1/builds/196/downloads/paper-1.20.1-196.jar" "1.20.1" "21";;
        4) install_papermc "https://api.papermc.io/v2/projects/paper/versions/1.20/builds/17/downloads/paper-1.20-17.jar" "1.20" "21";;
        5) install_papermc "https://api.papermc.io/v2/projects/paper/versions/1.19.4/builds/550/downloads/paper-1.19.4-550.jar" "1.19.4" "21";;
        6) install_papermc "https://api.papermc.io/v2/projects/paper/versions/1.19.3/builds/448/downloads/paper-1.19.3-448.jar" "1.19.3" "21";;
        7) install_papermc "https://api.papermc.io/v2/projects/paper/versions/1.19.2/builds/307/downloads/paper-1.19.2-307.jar" "1.19.2" "21";;
        8) install_papermc "https://api.papermc.io/v2/projects/paper/versions/1.19.1/builds/111/downloads/paper-1.19.1-111.jar" "1.19.1" "21";;
        9) install_papermc "https://api.papermc.io/v2/projects/paper/versions/1.19/builds/81/downloads/paper-1.19-81.jar" "1.19" "21";;
        10) install_papermc "https://api.papermc.io/v2/projects/paper/versions/1.18.2/builds/379/downloads/paper-1.18.2-379.jar" "1.18.2" "21";;
        11) install_papermc "https://papermc.io/api/v2/projects/paper/versions/1.18.1/builds/216/downloads/paper-1.18.1-216.jar" "1.18.1" "21";;
        12) install_papermc "https://papermc.io/api/v2/projects/paper/versions/1.18/builds/66/downloads/paper-1.18-66.jar" "1.18" "21";;
        13) install_papermc "https://papermc.io/api/v2/projects/paper/versions/1.17.1/builds/408/downloads/paper-1.17.1-408.jar" "1.17.1" "21";;
        14) install_papermc "https://papermc.io/api/v2/projects/paper/versions/1.17/builds/66/downloads/paper-1.17-66.jar" "1.17" "21";;
        15) install_papermc "https://papermc.io/api/v2/projects/paper/versions/1.16.5/builds/790/downloads/paper-1.16.5-790.jar" "1.16.5" "16";;
        16) install_papermc "https://papermc.io/api/v2/projects/paper/versions/1.16.4/builds/416/downloads/paper-1.16.4-416.jar" "1.16.4" "11";;
        17) install_papermc "https://papermc.io/api/v2/projects/paper/versions/1.16.3/builds/253/downloads/paper-1.16.3-253.jar" "1.16.3" "11";;
        18) install_papermc "https://papermc.io/api/v2/projects/paper/versions/1.16.2/builds/189/downloads/paper-1.16.2-189.jar" "1.16.2" "11";;
        19) install_papermc "https://papermc.io/api/v2/projects/paper/versions/1.16.1/builds/138/downloads/paper-1.16.1-138.jar" "1.16.1" "11";;
        20) install_papermc "https://papermc.io/api/v2/projects/paper/versions/1.15.2/builds/391/downloads/paper-1.15.2-391.jar" "1.15.2" "11";;
        21) install_papermc "https://papermc.io/api/v2/projects/paper/versions/1.14.4/builds/243/downloads/paper-1.14.4-243.jar" "1.14.4" "11";;
        22) install_papermc "https://papermc.io/api/v2/projects/paper/versions/1.13.2/builds/655/downloads/paper-1.13.2-655.jar" "1.13.2" "11";;
        23) install_papermc "https://papermc.io/api/v2/projects/paper/versions/1.12.2/builds/1618/downloads/paper-1.12.2-1618.jar" "1.12.2" "11";;
        24) install_papermc "https://papermc.io/api/v2/projects/paper/versions/1.11.2/builds/1104/downloads/paper-1.11.2-1104.jar" "1.11.2" "8";;
        25) install_papermc "https://papermc.io/api/v2/projects/paper/versions/1.10.2/builds/916/downloads/paper-1.10.2-916.jar" "1.10.2" "8";;
        26) install_papermc "https://papermc.io/api/v2/projects/paper/versions/1.9.4/builds/773/downloads/paper-1.9.4-773.jar" "1.9.4" "8";;
        27) install_papermc "https://papermc.io/api/v2/projects/paper/versions/1.8.8/builds/443/downloads/paper-1.8.8-443.jar" "1.8.8" "8";;
        0) echo "Saliendo..."; exit 0;;
        *) echo "Opción no válida. Inténtelo de nuevo.";;
    esac
done