@echo off
cd /d "%~dp0"

::============= Общий банлист ==============
if not exist "blacklist.txt" (echo.>blacklist.txt)
set "input_file=C:\Conan\Script\blacklist_ALL.txt"
set "output_file=C:\Conan\Script\blacklist_ALL.TMP"
:: запишем содержимое банлиста в общий файл, на случай если банили на серевере.
powershell -command "Add-Content -Path 'C:\Conan\Script\blacklist_ALL.txt' -Value ''"
powershell -command "Add-Content -Path 'C:\Conan\Script\blacklist_ALL.txt' -Value (Get-Content -Path 'blacklist.txt')"
:: удалим дубликаты записей в списке
if exist "%output_file%" del "%output_file%"
if exist "%input_file%" (
powershell -command "Get-Content '%input_file%' | Select-Object -Unique | Set-Content '%output_file%'"
move /y "%output_file%" "%input_file%" > nul
)
:: удалим пустые строки в списке
powershell -command "gc '%input_file%' | where {$_.Length -gt 0} > '%output_file%'"
move /y "%output_file%" "%input_file%" > nul
::перезапишем банлист из общего списка банов
powershell -command "Set-Content -Path 'blacklist.txt' -Value (Get-Content -Path '%input_file%')"
::============= END Общий банлист ==============

:: путь к скриптам
set scriptdir=C:\Conan\Script\OnStart
:: какие файлы базы данных обрабатывать
set "database=Game.db DLC_Siptah.db savagewilds_game.db"

:: проверим путь к скриптам
IF NOT EXIST "%scriptdir%" (
CALL:ECHORED "Directrory %scriptdir% NOT FOUD"
CALL:ECHORED "SCRIPTS NOT APLLED"
TIMEOUT /T 10 & exit
)	else (
		CALL:ECHOGreen "Scritps path is - %scriptdir%")

CALL:ECHOGreen "=====start work======"

:: применить цикл к списку баз данных для обработки
:Start 
for %%f in (%database%) do (
	set "gamedatabase=%%f"
    if exist "%%f" (
        echo Found database: %%f
		call :CYCLE
    ) else (
        echo.
    )
)

::echo Inserting timestamp to database...
::sqlite3.exe Game.db "delete from dw_settings where name like 'serverruntime'"
::sqlite3.exe Game.db "insert into dw_settings(name, value) select 'serverruntime', '86400'"
::echo Complete!..

:Exit
TIMEOUT /T 2
exit

:: блок применения скриптов
:CYCLE
IF EXIST "%gamedatabase%.TMP" (DEL %gamedatabase%.TMP /q /f)
CALL:ECHOGreen "BackUp %gamedatabase% to %gamedatabase%.TMP"
COPY %gamedatabase% %gamedatabase%.TMP
:: блок применяемых криптов
CALL:ECHOGreen "=====apply SQL scripts======"
:: Получаем список файлов .sql в директории
for /r "%scriptdir%" %%f in (*.sql) do (
	CALL:ECHOCyan "apply %%f
	sqlite3.exe %gamedatabase% < "%%f")
:: конец блока скриптов
) else (echo %gamedatabase% Not Found)
echo.

:ECHORED
Powershell.exe write-host -foregroundcolor Red %1
goto :eof
:ECHOGreen
Powershell.exe write-host -foregroundcolor Green %1
goto :eof
:ECHOCyan
Powershell.exe write-host -foregroundcolor Cyan %1
goto :eof