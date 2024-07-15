---------------------------------------------------------------------
# Para Servidor Vanilla

```bash 
    cd ~
    sudo rm -r ./Testing_server
    git clone https://github.com/IvanCaceresS/Testing_server
    cd ~/Testing_server/Minecraft_Server
    chmod +x setup_minecraft_server_VANILLA.sh
    ./setup_minecraft_server_VANILLA.sh
```

# Para Servidor Forge (Se debe tener una carpeta de mods cargada en WeTransfer.)

```bash 
    cd ~
    sudo rm -r ./Testing_server
    git clone https://github.com/IvanCaceresS/Testing_server
    cd ~/Testing_server/Minecraft_Server
    chmod +x setup_minecraft_server_FORGE.sh
    ./setup_minecraft_server_FORGE.sh
```

# Para Servidor PaperMC con plugins

```bash 
    cd ~
    sudo rm -r ./Testing_server
    git clone https://github.com/IvanCaceresS/Testing_server
    cd ~/Testing_server/Minecraft_Server
    chmod +x setup_minecraft_server_PLUGINS.sh
    ./setup_minecraft_server_PLUGINS.sh
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


# AJUSTES VISUALES SERVER MINECRAFT
- CAMBIAR MOTD: https://mctools.org/motd-creator
- CAMBIAR IMAGEN: archivo.PNG si o si de 64x64 px : https://www.simpleimageresizer.com/. Luego pegarlo dentro de la carpeta minecraft_server

# PONER PONER UN MODPACK DE CURSEFORGE
- Cada modpack tiene sus reglas por lo que hay que descargar el ServerPack e instalarlo manualmente.
- Luego de iniciado se pueden unir con el modpack normal de CurseForge