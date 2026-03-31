@echo off
setlocal
chcp 65001 >nul

set MYSQL_USER=root

:: Получение пароля
if "%1"=="" (
    set /p MYSQL_PASSWORD="Введите пароль MySQL root: "
) else (
    set MYSQL_PASSWORD=%1
)

:: Создание временного файла конфигурации в темповой папке
set "MY_INI=%TEMP%\mysql_config_%RANDOM%.ini"

echo [client] > "%MY_INI%"
echo user=%MYSQL_USER% >> "%MY_INI%"
echo password="%MYSQL_PASSWORD%" >> "%MY_INI%"

:: Запуск баз данных
set MYSQL=mysql --defaults-extra-file="%MY_INI%" -t

echo === Запуск баз данных ===

for %%D in (db_1_transport db_2_racing db_3_booking db_4_organization_structure) do (
    echo.
    echo --- Инициализация %%D ---
    %MYSQL% < %%D\schema.sql
    %MYSQL% < %%D\data.sql
    echo --- Запросы %%D ---
    %MYSQL% < %%D\queries.sql
)

echo.
echo === Конец ===
endlocal
pause