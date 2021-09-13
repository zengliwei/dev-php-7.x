@echo off

cd /d %~dp0

set path=%path%;%~dp0..\..\cmd

for /f "tokens=1,2 delims==" %%i in (.env) do (
    if %%i == COMPOSE_PROJECT_NAME (
        set project=%%j
    ) else if %%i == DOMAIN (
        set domain=%%j
    )
)

call docker-compose down
call reset-phpmyadmin-config "%project%"
call remove-proxy-config "%domain%"
call reset-host-config "%domain%"

pause
