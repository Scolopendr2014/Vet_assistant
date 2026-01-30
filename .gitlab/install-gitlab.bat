@echo off
chcp 65001 >nul
echo === Установка GitLab через Docker ===
echo.

cd /d "%~dp0.."

echo Проверка Docker...
docker --version
if errorlevel 1 (
    echo Docker не установлен!
    echo Установите Docker Desktop: https://www.docker.com/products/docker-desktop/
    echo Или: winget install Docker.DockerDesktop
    pause
    exit /b 1
)
echo.

echo Создание папок для GitLab...
if not exist "gitlab\config" mkdir "gitlab\config"
if not exist "gitlab\logs" mkdir "gitlab\logs"
if not exist "gitlab\data" mkdir "gitlab\data"
echo.

echo Запуск GitLab (первый раз может занять 5-10 минут)...
docker-compose up -d
if errorlevel 1 (
    echo Ошибка при запуске. Проверьте: docker logs gitlab
    pause
    exit /b 1
)

echo.
echo GitLab запускается. Подождите 5-10 минут, затем откройте: http://localhost
echo Логин: root
echo Пароль получите командой: docker exec gitlab grep Password: /etc/gitlab/initial_root_password
echo.
pause
