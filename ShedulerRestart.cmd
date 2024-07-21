@echo off
cd %~dp0
chcp 65001
setlocal enabledelayedexpansion
title "Conan ShedulerRestart"

:: Run once to setup script in to windows task sheduler (taskschd.msc) 11:50 and 23:50 Autorun
schtasks /query /tn "Conan.Restart 1"
echo %errorlevel%
if %errorlevel% == 1 (
    echo Task not found. Adding task to the scheduler...
    schtasks /create /F /tn "Conan.Restart 1" /tr "\"%~dp0ShedulerRestart.cmd\"" /sc daily /st 11:50
    schtasks /create /F /tn "Conan.Restart 2" /tr "\"%~dp0ShedulerRestart.cmd\"" /sc daily /st 23:50
	echo exit
	timeout /t 5
	exit
)

set "rcon_dir=%~dp0"
set "WEBHOOK_URL=https://discord.com/api/webhooks/1222834102860910603/XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
set "ip=127.0.0.1"
set "rcon_port=17000"
set "rcon_pass=SUPER_PASSWORD"

REM Выполнить команду и посчитать строки
:: для mrcon -1 для pyrcon -5
set count=-5
for /f "delims=" %%a in ('"%rcon_dir%PyRcon.exe" -ip %ip% -p %rcon_port% -pass %rcon_pass% -c listplayers -t 4 -r 3') do (
    set /a count+=1
)


:: ANNONCE IN DISCORD
echo Discord annonce 1
set "MESSAGE=**Кластер**\n Плановый рестарт\n Сервер будет перезагружен через 10 минут"
set "rconmessage=Рестарт через 10 минут"
curl -H "Content-Type: application/json" -X POST -d "{\"content\":\"%MESSAGE%\"}" %WEBHOOK_URL%
for /L %%i in (0, 1, !count!) do (
    "%rcon_dir%PyRcon.exe" -ip %ip% -p %rcon_port% -pass %rcon_pass% -c "con %%i testfifo 2 %rconmessage%" -t 4 -r 3
)
timeout /t 300

echo Discord annonce 2
set "MESSAGE=**Кластер**\n Плановый рестарт\n Сервер будет перезагружен через 5 минут"
set "rconmessage=Рестарт через 5 минут"
curl -H "Content-Type: application/json" -X POST -d "{\"content\":\"%MESSAGE%\"}" %WEBHOOK_URL%
for /L %%i in (0, 1, !count!) do (
    "%rcon_dir%PyRcon.exe" -ip %ip% -p %rcon_port% -pass %rcon_pass% -c "con %%i testfifo 2 %rconmessage%" -t 4 -r 3
)
timeout /t 240

echo Discord annonce 3
set "MESSAGE=**Кластер**\n Плановый рестарт\n Сервер будет перезагружен через 1 минуту"
set "rconmessage=Рестарт через 1 минуту"
curl -H "Content-Type: application/json" -X POST -d "{\"content\":\"%MESSAGE%\"}" %WEBHOOK_URL%
for /L %%i in (0, 1, !count!) do (
    "%rcon_dir%PyRcon.exe" -ip %ip% -p %rcon_port% -pass %rcon_pass% -c "con %%i testfifo 2 %rconmessage%" -t 4 -r 3
)
timeout /t 60

echo Exiting Worlds...
"%rcon_dir%PyRcon.exe" -ip %ip% -p %rcon_port% -pass %rcon_pass% -c "shutdown" -t 4 -r 3

TIMEOUT /t 10

EXIT
