#!/bin/bash

# Actualiza el sistema e instala paquetes necesarios
sudo apt update
sudo apt upgrade -y
sudo apt install -y python3-pip python3-venv firewalld curl

# Inicia y habilita firewalld
sudo systemctl start firewalld
sudo systemctl enable firewalld

# Abre el puerto 5000 para Flask
sudo firewall-cmd --permanent --add-port=5000/tcp
sudo firewall-cmd --reload

# Crea un directorio para el proyecto Flask en el directorio home del usuario
mkdir ~/flask_project
cd ~/flask_project

# Crea y activa un entorno virtual
python3 -m venv venv
source venv/bin/activate

# Instala Flask dentro del entorno virtual
pip install Flask

# Obtiene la IP pública del sistema
PUBLIC_IP=$(curl -s ifconfig.me)

# Crea el archivo de la aplicación Flask
cat <<EOF > app.py
from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/')
def home():
    return "Hello, World!"

@app.route('/api', methods=['GET'])
def api():
    data = {
        'message': 'Hello from the API',
        'status': 'success'
    }
    return jsonify(data)

if __name__ == '__main__':
    print("Public IP Address: $PUBLIC_IP")
    print("Prueba la API en http://$PUBLIC_IP:5000/api")
    app.run(host='0.0.0.0', port=5000)
EOF

# Inicia el servidor Flask
echo "Iniciando el servidor Flask..."
python app.py
