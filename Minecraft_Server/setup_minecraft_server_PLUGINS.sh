#!/bin/bash

# Función para actualizar e instalar los paquetes necesarios
install_dependencies() {
    sudo apt update
    sudo apt upgrade -y
    sudo apt install -y wget screen unzip curl
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
    echo "1) 1.21"
    echo "2) 1.20.4"
    echo "3) 1.20.2"
    echo "4) 1.20.1"
    echo "5) 1.20"
    echo "6) 1.19.4"
    echo "7) 1.19.3"
    echo "8) 1.19.2"
    echo "9) 1.19.1"
    echo "10) 1.19"
    echo "11) 1.18.2"
    echo "12) 1.18.1"
    echo "13) 1.18"
    echo "14) 1.17.1"
    echo "15) 1.17"
    echo "16) 1.16.5"
    echo "17) 1.16.4"
    echo "18) 1.16.3"
    echo "19) 1.16.2"
    echo "20) 1.16.1"
    echo "21) 1.15.2"
    echo "22) 1.14.4"
    echo "23) 1.13.2"
    echo "24) 1.12.2"
    echo "25) 1.11.2"
    echo "26) 1.10.2"
    echo "27) 1.9.4"
    echo "28) 1.8.8"
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
    local spawn_protection="16"

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
    read -p "Rango de spawn_protection [$spawn_protection]: " input
    spawn_protection=${input:-$spawn_protection}

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
spawn-protection=$spawn_protection
resource-pack-sha1=
max-world-size=29999984
EOL
}

# Función para descargar plugins desde WeTransfer
download_plugins() {
    local plugins_dir=$1
    local url
    local output_file="plugins.zip"
    
    mkdir -p "$plugins_dir"
    chmod 775 "$plugins_dir"
    
    read -p "Ingrese el enlace de WeTransfer para los plugins: " url

    if [ -z "$url" ]; then
        echo "No se proporcionó un enlace de WeTransfer. No se instalarán plugins."
        return
    fi

    curl "$url" --location --output "${plugins_dir}/${output_file}"
    
    if [ $? -ne 0 ]; then
        echo "Error al descargar el archivo desde WeTransfer. Verifique el enlace y vuelva a intentarlo."
        return
    fi

    unzip "${plugins_dir}/${output_file}" -d "${plugins_dir}"
    
    if [ $? -ne 0 ]; then
        echo "Error al descomprimir el archivo. Asegúrese de que el archivo esté en formato ZIP y vuelva a intentarlo."
        return
    fi

    # Mover los archivos .jar desde la carpeta Plugins al directorio plugins
    mv "${plugins_dir}/Plugins/"*.jar "$plugins_dir/"
    rm -rf "${plugins_dir}/Plugins"
    rm "${plugins_dir}/${output_file}"

    echo "Plugins importados correctamente desde WeTransfer."
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

    # Crear carpeta plugins y descargar plugins desde WeTransfer
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
        1) install_papermc "https://api.papermc.io/v2/projects/paper/versions/1.21/builds/109/downloads/paper-1.21-109.jar" "1.21" "21";;
        2) install_papermc "https://api.papermc.io/v2/projects/paper/versions/1.20.4/builds/398/downloads/paper-1.20.4-398.jar" "1.20.4" "21";;
        3) install_papermc "https://api.papermc.io/v2/projects/paper/versions/1.20.2/builds/318/downloads/paper-1.20.2-318.jar" "1.20.2" "21";;
        4) install_papermc "https://api.papermc.io/v2/projects/paper/versions/1.20.1/builds/196/downloads/paper-1.20.1-196.jar" "1.20.1" "21";;
        5) install_papermc "https://api.papermc.io/v2/projects/paper/versions/1.20/builds/17/downloads/paper-1.20-17.jar" "1.20" "21";;
        6) install_papermc "https://api.papermc.io/v2/projects/paper/versions/1.19.4/builds/550/downloads/paper-1.19.4-550.jar" "1.19.4" "21";;
        7) install_papermc "https://api.papermc.io/v2/projects/paper/versions/1.19.3/builds/448/downloads/paper-1.19.3-448.jar" "1.19.3" "21";;
        8) install_papermc "https://api.papermc.io/v2/projects/paper/versions/1.19.2/builds/307/downloads/paper-1.19.2-307.jar" "1.19.2" "21";;
        9) install_papermc "https://api.papermc.io/v2/projects/paper/versions/1.19.1/builds/111/downloads/paper-1.19.1-111.jar" "1.19.1" "21";;
        10) install_papermc "https://api.papermc.io/v2/projects/paper/versions/1.19/builds/81/downloads/paper-1.19-81.jar" "1.19" "21";;
        11) install_papermc "https://api.papermc.io/v2/projects/paper/versions/1.18.2/builds/379/downloads/paper-1.18.2-379.jar" "1.18.2" "21";;
        12) install_papermc "https://papermc.io/api/v2/projects/paper/versions/1.18.1/builds/216/downloads/paper-1.18.1-216.jar" "1.18.1" "21";;
        13) install_papermc "https://papermc.io/api/v2/projects/paper/versions/1.18/builds/66/downloads/paper-1.18-66.jar" "1.18" "21";;
        14) install_papermc "https://papermc.io/api/v2/projects/paper/versions/1.17.1/builds/408/downloads/paper-1.17.1-408.jar" "1.17.1" "21";;
        15) install_papermc "https://papermc.io/api/v2/projects/paper/versions/1.17/builds/66/downloads/paper-1.17-66.jar" "1.17" "21";;
        16) install_papermc "https://papermc.io/api/v2/projects/paper/versions/1.16.5/builds/790/downloads/paper-1.16.5-790.jar" "1.16.5" "16";;
        17) install_papermc "https://papermc.io/api/v2/projects/paper/versions/1.16.4/builds/416/downloads/paper-1.16.4-416.jar" "1.16.4" "11";;
        18) install_papermc "https://papermc.io/api/v2/projects/paper/versions/1.16.3/builds/253/downloads/paper-1.16.3-253.jar" "1.16.3" "11";;
        19) install_papermc "https://papermc.io/api/v2/projects/paper/versions/1.16.2/builds/189/downloads/paper-1.16.2-189.jar" "1.16.2" "11";;
        20) install_papermc "https://papermc.io/api/v2/projects/paper/versions/1.16.1/builds/138/downloads/paper-1.16.1-138.jar" "1.16.1" "11";;
        21) install_papermc "https://papermc.io/api/v2/projects/paper/versions/1.15.2/builds/391/downloads/paper-1.15.2-391.jar" "1.15.2" "11";;
        22) install_papermc "https://papermc.io/api/v2/projects/paper/versions/1.14.4/builds/243/downloads/paper-1.14.4-243.jar" "1.14.4" "11";;
        23) install_papermc "https://papermc.io/api/v2/projects/paper/versions/1.13.2/builds/655/downloads/paper-1.13.2-655.jar" "1.13.2" "11";;
        24) install_papermc "https://papermc.io/api/v2/projects/paper/versions/1.12.2/builds/1618/downloads/paper-1.12.2-1618.jar" "1.12.2" "11";;
        25) install_papermc "https://papermc.io/api/v2/projects/paper/versions/1.11.2/builds/1104/downloads/paper-1.11.2-1104.jar" "1.11.2" "8";;
        26) install_papermc "https://papermc.io/api/v2/projects/paper/versions/1.10.2/builds/916/downloads/paper-1.10.2-916.jar" "1.10.2" "8";;
        27) install_papermc "https://papermc.io/api/v2/projects/paper/versions/1.9.4/builds/773/downloads/paper-1.9.4-773.jar" "1.9.4" "8";;
        28) install_papermc "https://papermc.io/api/v2/projects/paper/versions/1.8.8/builds/443/downloads/paper-1.8.8-443.jar" "1.8.8" "8";;
        0) echo "Saliendo..."; exit 0;;
        *) echo "Opción no válida. Inténtelo de nuevo.";;
    esac
done