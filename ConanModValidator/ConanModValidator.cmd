@echo off
cd %~dp0
chcp 65001>nul
setlocal enabledelayedexpansion

set root=%CD%
set "config_file=%root%\config.txt"
set STEAMCMD_URL=https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip
set STEAMCMD_PATH="%root%\SteamCMD\steamcmd.exe"
set APP_ID=440900
set INSTALL_DIR="%root%\renown"

:: ================ FUNCTIONS read config ======================================
goto SKIP_FUNCTIONS
:read_param
set "getparam=%~1"
for /f "delims=" %%a in ('powershell -Command "(Get-Content -Encoding UTF8 '%config_file%' | Where-Object {$_ -match '^\s*%getparam%='}) -replace '.*=', ''"') do (
    set "%getparam%=%%a"
)
exit /b
:forming_mod_list
set "tmp_arg="
for /f %%f in ('powershell -command "Get-ChildItem -Directory '!Mod_Dir!' | Where-Object { $_.Name -match '^\d+$' } | ForEach-Object { $_.Name }"') do (
    set "tmp_arg=!tmp_arg! +workshop_download_item 440900 %%f validate"
)
set additional_arg=!tmp_arg!
goto :eof
exit /b
:select_folder
for /f "delims=" %%i in ('powershell -command "$shell = New-Object -ComObject Shell.Application; $folder = $shell.BrowseForFolder(0, 'Расположение Conan Exiles. Библиотека стим-> Пкм на Conan-> Управление-> Просмотреть локальные файлы, например: Steam\steamapps\common\Conan Exiles', 16); if ($folder) { $folder.Self.Path } else { '' }"') do (
set "game_path=%%i"
set "mod_path=!game_path!\..\..\workshop\content\440900"
for /f "delims=" %%b in ('powershell -command "[System.IO.Path]::GetFullPath('!mod_path!')"') do set Mod_Dir=%%b
)

if not exist "!game_path!\ConanSandbox.exe" (
    echo Ошибка: В выбранной директории не найден ConanSandbox.exe. Пожалуйста, выберите правильную папку Conan Exiles.
    goto :select_folder
)

if not defined Mod_Dir (
    echo Выбор отменён. Выход.
	pause
    exit /b
) else (
echo Mod_Dir=!Mod_Dir!>"%config_file%"
)
goto :eof
exit /b
:SKIP_FUNCTIONS

:: ================ MAIN BLOCK ======================================
if exist "%config_file%" (
    cls
    call :read_param Mod_Dir
    if defined Mod_Dir (
        if exist "!Mod_Dir!" (
            ::echo Mod Dir !Mod_Dir!
			echo.
        ) else (
            echo Директория c модами "!Mod_Dir!" не найдена
            call :select_folder
        )
    ) else (
        echo Mod_Dir не определена в файле. Выберите папку Conan Exiles.
        call :select_folder
    )
) else (
    echo Файл config.txt не найден. Выберите папку Conan Exiles.
    call :select_folder
)

if exist "!Mod_Dir!" (
	echo.
) else (
	echo Директория c модами "!Mod_Dir!" не найдена
	call :select_folder
	goto SKIP_FUNCTIONS
)

:: Only Sync and Start
::goto SyncModList

:MAIN
if not exist SteamCMD mkdir SteamCMD
if exist SteamCMD.zip (
    del /F SteamCMD.zip
)

if not exist %STEAMCMD_PATH% (
	echo Downloading SteamCMD...
	curl -o SteamCMD.zip %STEAMCMD_URL%
	if errorlevel 1 (
		echo Error: Download SteamCMD.zip failed.
		timeout /t 3
		exit /b 1
	)
	echo Extracting file...
	tar -xf SteamCMD.zip -C SteamCMD
	if errorlevel 1 (
		echo Error: Extraction SteamCMD.zip failed. Ensure tar is available or file is valid.
		timeout /t 3
		exit /b 1
	)
	if exist SteamCMD.zip (
		del /F SteamCMD.zip
	)
	echo Download and extraction complete.
	timeout /t 3
)

if not exist %STEAMCMD_PATH% (
    echo SteamCMD not found at %STEAMCMD_PATH%. Please update the path.
    timeout /t 3
)

Echo Unlock mods, Kill ConanSandbox / BEService_x64 / ConanSandbox_BE
taskkill /IM ConanSandbox.exe /F
taskkill /IM ConanSandbox_BE.exe /F
taskkill /IM BEService_x64.exe /F
timeout /t 3
cls
Echo Start Update mods
echo Mod Dir: !Mod_Dir!

:: Get RealModDir
for /f "delims=" %%c in ('powershell -command "[System.IO.Path]::GetFullPath('!Mod_Dir!\..\..\..\..')"') do (set Real_Mod_Dir=%%c)
if exist "!Real_Mod_Dir!" (
	call :forming_mod_list
	echo Update steamcmd
	%STEAMCMD_PATH% +@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +force_install_dir "!Real_Mod_Dir!" +login anonymous -beta default validate +quit
	cls
	%STEAMCMD_PATH% +@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +force_install_dir "!Real_Mod_Dir!" +login anonymous -beta default validate !additional_arg! +quit
) else (
	echo Директория c модами "!Real_Mod_Dir!\steamapps\workshop\content\440900" не найдена
	goto SKIP_FUNCTIONS
)
echo Update Success

:SyncModList
echo Sync Server ModList
if exist "!Mod_Dir!\..\..\..\common\Conan Exiles\ConanSandbox\servermodlist.txt" (
    echo Sync Server ModList
	md "!Mod_Dir!\..\..\..\common\Conan Exiles\ConanSandbox\Mods" 2>nul
    copy "!Mod_Dir!\..\..\..\common\Conan Exiles\ConanSandbox\servermodlist.txt" "!Mod_Dir!\..\..\..\common\Conan Exiles\ConanSandbox\Mods\modlist.txt"
)

Echo Start Conan Exiles
start "" "!Mod_Dir!\..\..\..\common\Conan Exiles\ConanSandbox\Binaries\Win64\ConanSandbox_BE.exe" --continuesession

timeout /t 3
exit /b 1
