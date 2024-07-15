#!/bin/bash

# Solicitar la ruta del script que se desea ejecutar al inicio
read -p "Introduce la ruta completa del script que deseas ejecutar al inicio: " script_path

# Crear el script de inicio
cat <<EOL > /usr/local/bin/startup-script.sh
#!/bin/bash
$script_path
EOL

# Hacer el script ejecutable
chmod +x /usr/local/bin/startup-script.sh

# Crear el archivo de servicio de systemd
cat <<EOL > /etc/systemd/system/startup-script.service
[Unit]
Description=Ejecutar script al inicio

[Service]
ExecStart=/usr/local/bin/startup-script.sh

[Install]
WantedBy=multi-user.target
EOL

# Recargar systemd para que reconozca el nuevo servicio
systemctl daemon-reload

# Habilitar el servicio para que se ejecute al inicio
systemctl enable startup-script.service

echo "El script se ha configurado para ejecutarse al inicio."
