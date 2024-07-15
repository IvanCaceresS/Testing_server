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

# Función para descargar e instalar la versión seleccionada
install_papermc() {
    local url=$1
    local version=$2
    local java_version=$3

    # Instalar la versión de Java correspondiente
    install_java $java_version

    # Crear directorio para el servidor
    mkdir -p ~/papermc/$version

    # Descargar el archivo
    wget -O ~/papermc/$version/server.jar $url

    # Solicitar la cantidad de RAM
    local total_mem=$(free -m | awk '/^Mem:/{print $2}')
    local max_mem=$(($total_mem * 80 / 100))M

    while true; do
        read -p "Ingrese la cantidad de RAM para el servidor (512M - $max_mem): " ram
        if [[ $ram =~ ^[0-9]+[MG]$ ]] && [[ ${ram%[MG]} -ge 512 ]] && [[ ${ram%[MG]} -le ${max_mem%M} ]]; then
            break
        else
            echo "Cantidad de RAM no válida. Intente nuevamente."
        fi
    done

    # Crear el script de inicio
    echo "#!/bin/bash" > ~/papermc/$version/start.sh
    echo "screen -dmS papermc_server java -Xms$ram -Xmx$ram -jar server.jar --nogui" >> ~/papermc/$version/start.sh

    # Hacer ejecutable el script de inicio
    chmod +x ~/papermc/$version/start.sh

    echo "PaperMC $version se ha descargado e instalado en ~/papermc/$version"
    echo "Use '~/papermc/$version/start.sh' para iniciar el servidor."
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
