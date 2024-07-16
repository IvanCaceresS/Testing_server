@echo off
setlocal enabledelayedexpansion

:: Obtener la fecha y hora actual
for /f "tokens=1-4 delims=/. " %%a in ('date /t') do (
    set day=%%a
    set month=%%b
    set year=%%c
)
for /f "tokens=1-2 delims=:" %%a in ('time /t') do (
    set hour=%%a
    set minute=%%b
)

:: Ajustar el formato del día y hora para eliminar espacios en blanco
set hour=%hour: =%
set minute=%minute: =%
if %hour% lss 10 set hour=0%hour%
if %minute% lss 10 set minute=0%minute%

:: Crear el timestamp en el formato dd-mm-aaaa-hh.mm
set TIMESTAMP=%day%-%month%-%year%-%hour%h.%minute%m

:: Configurar las variables
set SERVER_IP=159.112.129.245
set USERNAME=ubuntu
set REMOTE_PATH=/home/ubuntu/papermc/1.20/
set LOCAL_PATH=F:\Copias_Seguridad_Viltrum
set KEY_PATH=F:\LlavesPEM\Ubuntu-22.04_4core_24GB.key

:: Crear la carpeta de destino con el timestamp
set DEST_DIR=%LOCAL_PATH%\%TIMESTAMP%
mkdir %DEST_DIR%

:: Copiar toda la carpeta 1.20 usando scp
scp -i "%KEY_PATH%" -r %USERNAME%@%SERVER_IP%:%REMOTE_PATH% %DEST_DIR%

echo Backup completado: %DEST_DIR%
pause
