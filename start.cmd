@echo off

cd /d %~dp0

set path=%path%;%~dp0..\..\cmd
set project=%dirName%

for /f "tokens=1,2 delims==" %%i in (.\.env) do (
    if %%i == COMPOSE_PROJECT_NAME (
        set project=%%j
    ) else if %%i == DOMAIN (
        set domain=%%j
    ) else if %%i == DB_USER (
        set dbUser=%%j
    ) else if %%i == DB_PSWD (
        set dbPass=%%j
    )
)

::::
:: Start project containers if created, otherwise create them
::
for /f "skip=1" %%c in ('docker ps -a --filter "name=%project%_web"') do (
    if not %%c == '' (
        call start-project "%domain%"
        exit
    )
)

call add-host-record "%domain%"
call create-proxy-config "%project%" "%domain%"
call docker-compose up --no-recreate -d
call config-phpmyadmin "%project%" "%dbUser%" "%dbPass%"
call decompress-packets "%project%"
call start-project "%domain%"
