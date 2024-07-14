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
        read -p "$1 [Máx: ${max_mem}M, ej. 512M, 2G]: " input
        input=${input:-"${max_mem}M"}  # Valor por defecto es el máximo calculado
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
        if [[ "$input" =~ ^https://launcher.mojang.com ]] || [[ "$input" =~ ^https://maven.minecraftforge.net ]]; then
            echo "$input"
            return
        else
            echo "Por favor, ingrese una URL válida que comience con https://launcher.mojang.com o https://maven.minecraftforge.net"
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

# Selección del tipo de servidor
server_type=$(prompt "Elige el tipo de servidor (vanilla, forge)" "vanilla" "vanilla forge")

if [ "$server_type" == "vanilla" ]; then
    # Selección de la versión del servidor vanilla
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
            server_url=$(prompt_url "Ingresa la URL personalizada del servidor, puedes obtenerla de: https://mcversions.net/" "https://launcher.mojang.com/v1/objects/84194a2f286ef7c14ed7ce0090dba59902951553/server.jar")
            ;;
    esac
else
    # Selección de la versión del servidor forge
    version=$(prompt "Elige la versión del servidor de Minecraft con forge:
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
        "OTRA")
            server_url=$(prompt_url "Ingresa la URL personalizada del servidor, puedes obtenerla de: https://files.minecraftforge.net/net/minecraftforge/forge/" "https://maven.minecraftforge.net/net/minecraftforge/forge/1.20.1-47.3.0/forge-1.20.1-47.3.0-installer.jar")
            ;;
    esac
fi

# Configuración de EULA
eula_agree=$(prompt "¿Aceptas el EULA de Minecraft? (yes/no)" "yes" "yes no")
if [ "$eula_agree" != "yes" ]; then
    echo "Debes aceptar el EULA para continuar."
    exit 1
fi

# Creación del directorio del servidor
server_directory=$(prompt_text "Ingresa el nombre del directorio del servidor" "minecraft_server")
mkdir -p "$server_directory"
cd "$server_directory"

# Descarga del servidor
wget -O server.jar "$server_url"

# Aceptación del EULA
echo "eula=true" > eula.txt

# Selección de la cantidad de memoria asignada
memoria=$(prompt_memory "¿Cuánta memoria RAM quieres asignar al servidor?")

# Creación del script de inicio del servidor
cat <<EOF > start.sh
#!/bin/bash
java -Xmx$memoria -Xms$memoria -jar server.jar nogui
EOF

chmod +x start.sh

# Ejecución del servidor en una sesión de screen
screen -dmS mc_server ./start.sh

echo "El servidor de Minecraft se está iniciando en una sesión de screen llamada 'mc_server'."
