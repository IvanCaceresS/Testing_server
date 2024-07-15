#!/bin/bash

# Actualiza el sistema e instala paquetes necesarios
sudo apt update
sudo apt upgrade -y
sudo apt install -y python3-pip python3-venv

# Crea un directorio para el proyecto Flask
mkdir flask_project
cd flask_project

# Crea y activa un entorno virtual
python3 -m venv venv
source venv/bin/activate

# Instala Flask dentro del entorno virtual
pip install Flask

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
    app.run(host='0.0.0.0', port=5000)
EOF

# Inicia el servidor Flask
echo "Iniciando el servidor Flask..."
python app.py
