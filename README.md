# Testing_server
Este repositorio sirve para testear un servidor en cloud.

# Conectarse vía SSH
ssh -i LLAVE.KEY/LLAVE.PEM usuario@IP

# Entorno virtual
sudo apt-get update
sudo apt install python3 python3-venv python3-pip
python3 -m venv myenv
source myenv/bin/activate

# Habilitar puertos en maquina
sudo apt install firewalld
sudo firewall-cmd --permanent --zone=public --add-port=80/tcp
sudo firewall-cmd --permanent --zone=public --add-port=80/udp
sudo firewall-cmd --permanent --zone=public --add-port=5000/tcp
sudo firewall-cmd --permanent --zone=public --add-port=5000/udp
sudo firewall-cmd --reload