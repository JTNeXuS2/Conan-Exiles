@echo off
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Положить батник в директорию
:: Файл DedicatedServerLauncher*.exe положить в Server1
:: Для добавления серверов просто дублируем блок Проверки от "Server Check Start Block" до "Server Check End  Block"
:: в Новом блоке обязательно сменить Идентификатор сервера "set server=Server1"
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

cd %~dp0
chcp 65001
mode con:cols=70 lines=8
title Conan DSL WachDog
setlocal enabledelayedexpansion

:KILL
:: FIND PID Path
cls
color 0E

:: Server Check Start Block ::::::::::::::::::::::::::::::::::::::::
set server=Server1
echo Check !server!
set "ProcessId="
set "ConanSandboxServer="
set "DSL="
:: Автоматическое определение версии файла DedicatedServerLauncher*.exe
set "LauncherFile="
for /f "delims=" %%f in ('dir /b "!server!\DedicatedServerLauncher*.exe" 2^>nul') do (
    if not defined LauncherFile (
        color 02
        set "LauncherFile=%%f"
        echo Found launcher file: !LauncherFile!
    )
)
if not defined LauncherFile (
    color 04
    echo Error: DedicatedServerLauncher*.exe not found in !server!\ 
    timeout /t 2 > nul
    goto :eof
)
color 0E
set "WorkingDir=!server!\DedicatedServerLauncher\ConanExilesDedicatedServer\ConanSandbox\Binaries\Win64\ConanSandboxServer-Win64-Shipping.exe"
for /f "delims=" %%i in ('powershell.exe -command "$Processes = Get-Process; $Processes | Where-Object { $_.Path -like '*!WorkingDir%!' } | Select-Object -ExpandProperty Id"') do (
    set "ConanSandboxServer=1"
    set "ProcessId=%%i"
)
set "DSLDir=!server!\!LauncherFile!"
for /f "delims=" %%i in ('powershell.exe -command "$Processes = Get-Process; $Processes | Where-Object { $_.Path -like '*!DSLDir%!' } | Select-Object -ExpandProperty Id"') do (
    set "DSL=1"
)
set "WindowTitle=SteamCMD Batch File" && set "processpid="
for /f "tokens=*" %%a in ('powershell.exe -command "$Processes = Get-Process; $Processes | Where-Object {$_.MainWindowTitle -like '*%WindowTitle%*'} | ForEach-Object {Write-Output $_.Id}"') do set processpid=%%a
if not "%processpid%"=="" (
    color 02
    echo Found %WindowTitle% PID: %processpid% SKIPED
	timeout /t 2 > nul
) else (
    echo. && echo Process %WindowTitle% not run. Continue Check...
    :: Исправленная проверка: OR для неопределенных переменных
    if not defined ConanSandboxServer (
        echo Process not found ConanSandboxServer-Win64-Shipping.exe
        call :killserver
    ) else if not defined DSL (
        echo Process not found !server!\!LauncherFile!
        call :killserver
    ) else (
        call :found
    )
)
timeout /t 1 > nul
:: Server Check End  Block ::::::::::::::::::::::::::::::::::::::::

:: Server Check Start Block ::::::::::::::::::::::::::::::::::::::::
set server=Server2
echo Check !server!
set "ProcessId="
set "ConanSandboxServer="
set "DSL="
:: Автоматическое определение версии файла DedicatedServerLauncher*.exe
set "LauncherFile="
for /f "delims=" %%f in ('dir /b "!server!\DedicatedServerLauncher*.exe" 2^>nul') do (
    if not defined LauncherFile (
        color 02
        set "LauncherFile=%%f"
        echo Found launcher file: !LauncherFile!
    )
)
if not defined LauncherFile (
    color 04
    echo Error: DedicatedServerLauncher*.exe not found in !server!\ 
    timeout /t 2 > nul
    goto :eof
)
color 0E
set "WorkingDir=!server!\DedicatedServerLauncher\ConanExilesDedicatedServer\ConanSandbox\Binaries\Win64\ConanSandboxServer-Win64-Shipping.exe"
for /f "delims=" %%i in ('powershell.exe -command "$Processes = Get-Process; $Processes | Where-Object { $_.Path -like '*!WorkingDir%!' } | Select-Object -ExpandProperty Id"') do (
    set "ConanSandboxServer=1"
    set "ProcessId=%%i"
)
set "DSLDir=!server!\!LauncherFile!"
for /f "delims=" %%i in ('powershell.exe -command "$Processes = Get-Process; $Processes | Where-Object { $_.Path -like '*!DSLDir%!' } | Select-Object -ExpandProperty Id"') do (
    set "DSL=1"
)
set "WindowTitle=SteamCMD Batch File" && set "processpid="
for /f "tokens=*" %%a in ('powershell.exe -command "$Processes = Get-Process; $Processes | Where-Object {$_.MainWindowTitle -like '*%WindowTitle%*'} | ForEach-Object {Write-Output $_.Id}"') do set processpid=%%a
if not "%processpid%"=="" (
    color 02
    echo Found %WindowTitle% PID: %processpid% SKIPED
	timeout /t 2 > nul
) else (
    echo. && echo Process %WindowTitle% not run. Continue Check...
    :: Исправленная проверка: OR для неопределенных переменных
    if not defined ConanSandboxServer (
        echo Process not found ConanSandboxServer-Win64-Shipping.exe
        call :killserver
    ) else if not defined DSL (
        echo Process not found !server!\!LauncherFile!
        call :killserver
    ) else (
        call :found
    )
)
timeout /t 1 > nul
:: Server Check End  Block ::::::::::::::::::::::::::::::::::::::::


:: END
color 02
timeout /t 160
goto KILL

:: Restart Function
:killserver
color 04
set "WorkingDir=!server!\!LauncherFile!"
echo Выполняем остановку DSL !LauncherFile!. 
powershell.exe -command "$Processes = Get-Process; $Processes | Where-Object { $_.Path -like '*!WorkingDir!*' } | ForEach-Object { Stop-Process -Id $_.Id }"
timeout /t 1 > nul
echo Выполняем запуск DSL !LauncherFile!. 
start !server!\!LauncherFile!
timeout /t 13 > nul
goto :eof
:found
echo Found ConanSandboxServer-Win64-Shipping.exe с ID: %ProcessId%
goto :eof
:end_check
goto :eof
