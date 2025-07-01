@echo off
cd %~dp0
chcp 65001
mode con:cols=70 lines=8

title Conan DSL WachDog

setlocal enabledelayedexpansion


:KILL
:: FIND PID Path
cls

::Server 1
set server=Server1
echo Check !server!
set "ProcessId="
set "ProcessFound="
set "WorkingDir=!server!\DedicatedServerLauncher\ConanExilesDedicatedServer\ConanSandbox\Binaries\Win64\ConanSandboxServer-Win64-Shipping.exe"
for /f "delims=" %%i in ('powershell.exe -command "$Processes = Get-Process; $Processes | Where-Object { $_.Path -like '*!WorkingDir%!' } | Select-Object -ExpandProperty Id"') do (
    set "ProcessFound=1"
    set "ProcessId=%%i"
)
set "WindowTitle=SteamCMD Batch File" && set "processpid="
for /f "tokens=*" %%a in ('powershell.exe -command "$Processes = Get-Process; $Processes | Where-Object {$_.MainWindowTitle -like '*%WindowTitle%*'} | ForEach-Object {Write-Output $_.Id}"') do set processpid=%%a
if not "%processpid%"=="" (
    echo Found %WindowTitle% PID: %processpid% SKIPED
	timeout /t 2 > nul
) else (
    echo Process %WindowTitle% not found
	if not defined ProcessFound (
		echo Процесс не найден ConanSandboxServer-Win64-Shipping.exe 
		:: KILL
		set "WorkingDir=!server!\DedicatedServerLauncher1710.exe"
		powershell.exe -command "$Processes = Get-Process; $Processes | Where-Object { $_.Path -like '*!WorkingDir!*' } | ForEach-Object { Stop-Process -Id $_.Id }"
		echo Выполняем перезапуск DedicatedServerLauncher. 
		timeout /t 1 > nul
		start !server!\DedicatedServerLauncher1710.exe
		timeout /t 10 > nul
	) else (
		echo Найден ConanSandboxServer-Win64-Shipping.exe с ID: %ProcessId%
	)
)
timeout /t 1

::Server 2
set server=Server2
echo Check !server!
set "ProcessId="
set "ProcessFound="
set "WorkingDir=!server!\DedicatedServerLauncher\ConanExilesDedicatedServer\ConanSandbox\Binaries\Win64\ConanSandboxServer-Win64-Shipping.exe"
for /f "delims=" %%i in ('powershell.exe -command "$Processes = Get-Process; $Processes | Where-Object { $_.Path -like '*!WorkingDir%!' } | Select-Object -ExpandProperty Id"') do (
    set "ProcessFound=1"
    set "ProcessId=%%i"
)
set "WindowTitle=SteamCMD Batch File" && set "processpid="
for /f "tokens=*" %%a in ('powershell.exe -command "$Processes = Get-Process; $Processes | Where-Object {$_.MainWindowTitle -like '*%WindowTitle%*'} | ForEach-Object {Write-Output $_.Id}"') do set processpid=%%a
if not "%processpid%"=="" (
    echo Found %WindowTitle% PID: %processpid% SKIPED
	timeout /t 2 > nul
) else (
    echo Process %WindowTitle% not found
	if not defined ProcessFound (
		echo Процесс не найден ConanSandboxServer-Win64-Shipping.exe 
		:: KILL
		set "WorkingDir=!server!\DedicatedServerLauncher1710.exe"
		powershell.exe -command "$Processes = Get-Process; $Processes | Where-Object { $_.Path -like '*!WorkingDir!*' } | ForEach-Object { Stop-Process -Id $_.Id }"
		echo Выполняем перезапуск DedicatedServerLauncher. 
		timeout /t 1 > nul
		start !server!\DedicatedServerLauncher1710.exe
		timeout /t 10 > nul
	) else (
		echo Найден ConanSandboxServer-Win64-Shipping.exe с ID: %ProcessId%
	)
)
timeout /t 1

set server=Server3
echo Check !server!
set "ProcessId="
set "ProcessFound="
set "WorkingDir=!server!\DedicatedServerLauncher\ConanExilesDedicatedServer\ConanSandbox\Binaries\Win64\ConanSandboxServer-Win64-Shipping.exe"
for /f "delims=" %%i in ('powershell.exe -command "$Processes = Get-Process; $Processes | Where-Object { $_.Path -like '*!WorkingDir%!' } | Select-Object -ExpandProperty Id"') do (
    set "ProcessFound=1"
    set "ProcessId=%%i"
)
set "WindowTitle=SteamCMD Batch File" && set "processpid="
for /f "tokens=*" %%a in ('powershell.exe -command "$Processes = Get-Process; $Processes | Where-Object {$_.MainWindowTitle -like '*%WindowTitle%*'} | ForEach-Object {Write-Output $_.Id}"') do set processpid=%%a
if not "%processpid%"=="" (
    echo Found %WindowTitle% PID: %processpid% SKIPED
	timeout /t 2 > nul
) else (
    echo Process %WindowTitle% not found
	if not defined ProcessFound (
		echo Процесс не найден ConanSandboxServer-Win64-Shipping.exe 
		:: KILL
		set "WorkingDir=!server!\DedicatedServerLauncher1710.exe"
		powershell.exe -command "$Processes = Get-Process; $Processes | Where-Object { $_.Path -like '*!WorkingDir!*' } | ForEach-Object { Stop-Process -Id $_.Id }"
		echo Выполняем перезапуск DedicatedServerLauncher. 
		timeout /t 1 > nul
		start !server!\DedicatedServerLauncher1710.exe
		timeout /t 10 > nul
	) else (
		echo Найден ConanSandboxServer-Win64-Shipping.exe с ID: %ProcessId%
	)
)
timeout /t 1

set server=Server4
echo Check !server!
set "ProcessId="
set "ProcessFound="
set "WorkingDir=!server!\DedicatedServerLauncher\ConanExilesDedicatedServer\ConanSandbox\Binaries\Win64\ConanSandboxServer-Win64-Shipping.exe"
for /f "delims=" %%i in ('powershell.exe -command "$Processes = Get-Process; $Processes | Where-Object { $_.Path -like '*!WorkingDir%!' } | Select-Object -ExpandProperty Id"') do (
    set "ProcessFound=1"
    set "ProcessId=%%i"
)
set "WindowTitle=SteamCMD Batch File" && set "processpid="
for /f "tokens=*" %%a in ('powershell.exe -command "$Processes = Get-Process; $Processes | Where-Object {$_.MainWindowTitle -like '*%WindowTitle%*'} | ForEach-Object {Write-Output $_.Id}"') do set processpid=%%a
if not "%processpid%"=="" (
    echo Found %WindowTitle% PID: %processpid% SKIPED
	timeout /t 2 > nul
) else (
    echo Process %WindowTitle% not found
	if not defined ProcessFound (
		echo Процесс не найден ConanSandboxServer-Win64-Shipping.exe 
		:: KILL
		set "WorkingDir=!server!\DedicatedServerLauncher1710.exe"
		powershell.exe -command "$Processes = Get-Process; $Processes | Where-Object { $_.Path -like '*!WorkingDir!*' } | ForEach-Object { Stop-Process -Id $_.Id }"
		echo Выполняем перезапуск DedicatedServerLauncher. 
		timeout /t 1 > nul
		start !server!\DedicatedServerLauncher1710.exe
		timeout /t 10 > nul
	) else (
		echo Найден ConanSandboxServer-Win64-Shipping.exe с ID: %ProcessId%
	)
)
timeout /t 1


:: END
timeout /t 160
goto KILL