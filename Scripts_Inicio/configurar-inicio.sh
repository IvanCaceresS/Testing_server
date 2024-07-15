#!/bin/bash

# Solicitar la ruta del script que se desea ejecutar al inicio
read -p "Introduce la ruta completa del script que deseas ejecutar al inicio: " script_path

# Expandir la tilde en la ruta, si es necesario
expanded_path=$(eval echo $script_path)

# Verificar si el archivo existe
if [ ! -f "$expanded_path" ]; then
  echo "El archivo $expanded_path no existe."
  exit 1
fi

# Crear el script de inicio
sudo bash -c "cat <<EOL > /usr/local/bin/startup-script.sh
#!/bin/bash
$expanded_path
EOL"

# Verificar si el script se ha creado correctamente
if [ $? -ne 0 ]; then
  echo "Error al crear el script de inicio."
  exit 1
fi

# Hacer el script ejecutable
sudo chmod +x /usr/local/bin/startup-script.sh

# Crear el archivo de servicio de systemd
sudo bash -c "cat <<EOL > /etc/systemd/system/startup-script.service
[Unit]
Description=Ejecutar script al inicio

[Service]
ExecStart=/usr/local/bin/startup-script.sh

[Install]
WantedBy=multi-user.target
EOL"

# Verificar si el archivo de servicio se ha creado correctamente
if [ $? -ne 0 ]; then
  echo "Error al crear el archivo de servicio de systemd."
  exit 1
fi

# Recargar systemd para que reconozca el nuevo servicio
sudo systemctl daemon-reload

# Habilitar el servicio para que se ejecute al inicio
sudo systemctl enable startup-script.service

echo "El script se ha configurado para ejecutarse al inicio."
