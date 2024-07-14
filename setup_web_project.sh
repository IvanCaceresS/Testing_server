#!/bin/bash

echo "Actualizando la lista de paquetes..."
sudo apt-get update

echo "Instalando firewalld..."
sudo apt-get install -y firewalld

echo "Configurando el firewall para permitir tráfico en los puertos 80 y 443..."
sudo firewall-cmd --permanent --zone=public --add-port=80/tcp
sudo firewall-cmd --permanent --zone=public --add-port=443/tcp
sudo firewall-cmd --reload

echo "Creando el directorio /var/www/html..."
sudo mkdir -p /var/www/html

echo "Instalando Git..."
sudo apt-get install -y git

while true; do
    read -p "Ingrese la URL del repositorio de GitHub que contiene su proyecto web: " repo_url
    echo "Clonando el repositorio desde $repo_url..."

    cd /tmp
    sudo git clone "$repo_url" proyecto-web

    if [ $? -ne 0 ]; then
        echo "No se pudo clonar el repositorio. Por favor, inténtelo nuevamente."
        continue
    fi

    if [ ! -f /tmp/proyecto-web/index.html ]; then
        echo "El repositorio clonado no contiene un archivo index.html. Eliminando el repositorio descargado..."
        sudo rm -rf /tmp/proyecto-web
        echo "Por favor, ingrese una URL de un repositorio que contenga un archivo index.html."
        continue
    fi

    echo "Copiando archivos del repositorio al directorio web..."
    sudo cp -a /tmp/proyecto-web/. /var/www/html/

    echo "Eliminando el repositorio clonado de /tmp..."
    sudo rm -rf /tmp/proyecto-web
    break
done

cd /var/www/html/

echo "Instalando Apache..."
sudo apt-get install -y apache2

echo "Iniciando Apache..."
sudo systemctl start apache2

echo "Habilitando Apache para que se inicie automáticamente al arrancar el sistema..."
sudo systemctl enable apache2

echo "Cambiando propietario de los archivos en /var/www/html/ a www-data..."
sudo chown -R www-data:www-data /var/www/html/

echo "Cambiando permisos de los archivos en /var/www/html/ a 755..."
sudo chmod -R 755 /var/www/html/

echo "Reiniciando Apache..."
sudo systemctl restart apache2

echo "Configuración completa. Ahora su proyecto web debería estar disponible en la dirección IP de su servidor."
echo "Abra un navegador web y escriba la IP de su servidor para ver su sitio web en funcionamiento."
echo "Por ejemplo: http://tu-ip-del-servidor"
