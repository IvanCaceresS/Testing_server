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

# Probar API FLASK
pip install -r simple_api_requirements.txt
python simple_api.py


---------------------------------------------------------------------
# PASOS PARA SERVIDOR DE MINECRAFT VANILLA

## Fuera del servidor, obtener link de Minecraft Server:

1. Visita: https://www.minecraft.net/es-es/download/server
2. Haz clic derecho en 'minecraft_server.1.21.jar' y selecciona "copiar link":
   - https://piston-data.mojang.com/v1/objects/450698d1863ab5180c25d7c804ef0fe6369dd1ba/server.jar
3. Reemplaza `piston-data` por `launcher`:
   - Este link se usará después: https://launcher.mojang.com/v1/objects/450698d1863ab5180c25d7c804ef0fe6369dd1ba/server.jar

## En servidor, sigue los siguientes pasos:

0. Abrit puertos 25556 TCP/UDP desde la consola de cloud (AWS / ORACLE)

1. Actualizar, instalar Java y configurar el firewall:
    ```bash
    sudo apt-get update && \
    sudo apt-get install -y openjdk-21-jre-headless firewalld screen && \
    sudo firewall-cmd --permanent --zone=public --add-port=25565/tcp && \
    sudo firewall-cmd --permanent --zone=public --add-port=25565/udp && \
    sudo firewall-cmd --reload
    ```

2. Crear el directorio del servidor, descargar el servidor de Minecraft y ejecutar el servidor por primera vez:
    ```bash
    mkdir ~/minecraft_server && \
    cd ~/minecraft_server && \
    wget https://launcher.mojang.com/v1/objects/450698d1863ab5180c25d7c804ef0fe6369dd1ba/server.jar && \
    java -Xmx512M -Xms512M -jar server.jar nogui
    ```

3. Aceptar el EULA:
    ```bash
    sed -i 's/eula=false/eula=true/' eula.txt
    ```

4. Configurar el servidor:
    ```bash
    nano server.properties
    ```
    - **Ejemplo de `server.properties`:**
        ```
        #Minecraft server properties
        #Wed Jul 10 16:32:04 UTC 2024
        accepts-transfers=false
        allow-flight=false
        allow-nether=true
        broadcast-console-to-ops=true
        broadcast-rcon-to-ops=true
        bug-report-link=
        difficulty=hard
        enable-command-block=false
        enable-jmx-monitoring=false
        enable-query=false
        enable-rcon=false
        enable-status=true
        enforce-secure-profile=true
        enforce-whitelist=false
        entity-broadcast-range-percentage=100
        force-gamemode=false
        function-permission-level=2
        gamemode=survival
        generate-structures=true
        generator-settings={}
        hardcore=false
        hide-online-players=false
        initial-disabled-packs=
        initial-enabled-packs=vanilla
        level-name=world
        level-seed=
        level-type=minecraft\:normal
        log-ips=true
        max-chained-neighbor-updates=1000000
        max-players=20
        max-tick-time=60000
        max-world-size=29999984
        motd=Servidor Ivan
        network-compression-threshold=256
        online-mode=false
        op-permission-level=4
        player-idle-timeout=0
        prevent-proxy-connections=false
        pvp=true
        query.port=25565
        rate-limit=0
        rcon.password=
        rcon.port=25575
        region-file-compression=deflate
        require-resource-pack=false
        resource-pack=
        resource-pack-id=
        resource-pack-prompt=
        resource-pack-sha1=
        server-ip=
        server-port=25565
        simulation-distance=10
        spawn-animals=true
        spawn-monsters=true
        spawn-npcs=true
        spawn-protection=16
        sync-chunk-writes=true
        text-filtering-config=
        use-native-transport=true
        view-distance=10
        white-list=false
        ```
    - **Fin del ejemplo**

5. Iniciar el servidor con `screen`:
    ```bash
    screen -S minecraft_server java -Xmx512M -Xms512M -jar server.jar nogui
    ```


### Notas:
- **Para desconectarte de la sesión de `screen` sin detener el servidor:** Presiona `Ctrl + A + D`.
- **Para volver a la sesión de `screen`:** 
    ```bash
    screen -r minecraft_server
    ```
- **Para listar todas las sesiones de `screen` en ejecución:**
    ```bash
    screen -ls
    ```
- **Para terminar la sesión de `screen` y detener el servidor:** Vuelve a la sesión y escribe `exit` o presiona `Ctrl + D`.

### Comandos adicionales:
- **Para iniciar el servidor con diferente memoria asignada:**
    ```bash
    java -Xmx512M -Xms512M -jar server.jar nogui
    java -Xmx1G -Xms1G -jar server.jar nogui
    ```
- **Para hacer admin del server a un jugador