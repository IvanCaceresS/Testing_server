# Testing_server
Este repositorio sirve para testear un servidor en cloud.

# Conectarse vía SSH
ssh -i LLAVE.KEY/LLAVE.PEM usuario@IP

# Entorno virtual
sudo apt update
sudo apt install python3 python3-venv python3-pip
python3 -m venv myenv
source myenv/bin/activate

# Habilitar puerto 80
sudo apt update
sudo apt install ufw
sudo ufw allow 80/tcp
sudo ufw allow 80/udp
sudo ufw enable
sudo ufw status

# Habilitar puerto 5000
sudo apt update
sudo apt install ufw
sudo ufw allow 5000/tcp
sudo ufw allow 5000/udp
sudo ufw enable
sudo ufw status
