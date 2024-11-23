@echo off
cd /d "%~dp0"
Chcp 65001
title "ConanChatCommands"
mode con:cols=70 lines=7

:start

setlocal
set "update_file=update.py"
set "target_file=ConanChatCommands.py"
if exist "%update_file%" (
    echo Файл %update_file% найден.
    rem Update ConanChatCommands.py from update.py
    copy /Y "%update_file%" "%target_file%"
    echo Update %target_file% from %update_file%.
) else (
    echo.
)
endlocal

echo Started
python ConanChatCommands.py
timeout /t 5
goto start
