# PowerShell скрипт для установки и настройки GitLab через Docker

Write-Host "=== Установка GitLab через Docker ===" -ForegroundColor Green

# Проверка Docker
Write-Host "`nПроверка Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version
    Write-Host "Docker установлен: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "Docker не установлен!" -ForegroundColor Red
    Write-Host "Установите Docker Desktop: https://www.docker.com/products/docker-desktop/" -ForegroundColor Yellow
    Write-Host "Или через winget: winget install Docker.DockerDesktop" -ForegroundColor Yellow
    exit 1
}

# Проверка Docker Compose
Write-Host "`nПроверка Docker Compose..." -ForegroundColor Yellow
try {
    $composeVersion = docker-compose --version
    Write-Host "Docker Compose установлен: $composeVersion" -ForegroundColor Green
} catch {
    Write-Host "Docker Compose не найден. Установка..." -ForegroundColor Yellow
    # Docker Compose обычно входит в Docker Desktop
}

# Создание папок
Write-Host "`nСоздание папок для GitLab..." -ForegroundColor Yellow
$folders = @('gitlab/config', 'gitlab/logs', 'gitlab/data')
foreach ($folder in $folders) {
    if (-not (Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder -Force | Out-Null
        Write-Host "Создана папка: $folder" -ForegroundColor Green
    }
}

# Проверка docker-compose.yml
Write-Host "`nПроверка docker-compose.yml..." -ForegroundColor Yellow
if (Test-Path 'docker-compose.yml') {
    Write-Host "Файл docker-compose.yml найден" -ForegroundColor Green
} else {
    Write-Host "Файл docker-compose.yml не найден!" -ForegroundColor Red
    exit 1
}

# Запуск GitLab
Write-Host "`nЗапуск GitLab..." -ForegroundColor Yellow
Write-Host "Это может занять 5-10 минут при первом запуске..." -ForegroundColor Yellow

docker-compose up -d

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nGitLab запущен!" -ForegroundColor Green
    Write-Host "`nОжидание готовности GitLab (это может занять несколько минут)..." -ForegroundColor Yellow
    
    $maxAttempts = 30
    $attempt = 0
    $ready = $false
    
    while ($attempt -lt $maxAttempts -and -not $ready) {
        Start-Sleep -Seconds 10
        $attempt++
        Write-Host "Попытка $attempt/$maxAttempts..." -ForegroundColor Gray
        
        try {
            $response = Invoke-WebRequest -Uri "http://localhost" -TimeoutSec 5 -UseBasicParsing -ErrorAction SilentlyContinue
            if ($response.StatusCode -eq 200) {
                $ready = $true
            }
        } catch {
            # Продолжаем ожидание
        }
    }
    
    if ($ready) {
        Write-Host "`n=== GitLab готов к использованию! ===" -ForegroundColor Green
        Write-Host "`nURL: http://localhost" -ForegroundColor Cyan
        Write-Host "Логин: root" -ForegroundColor Cyan
        
        # Получение начального пароля
        Write-Host "`nПолучение начального пароля..." -ForegroundColor Yellow
        $password = docker exec gitlab grep 'Password:' /etc/gitlab/initial_root_password 2>$null
        
        if ($password) {
            Write-Host "Пароль: $password" -ForegroundColor Cyan
        } else {
            Write-Host "Пароль ещё не сгенерирован. Попробуйте через несколько минут:" -ForegroundColor Yellow
            Write-Host "docker exec -it gitlab grep 'Password:' /etc/gitlab/initial_root_password" -ForegroundColor Gray
        }
        
        Write-Host "`nПолезные команды:" -ForegroundColor Yellow
        Write-Host "  Просмотр логов: docker logs -f gitlab" -ForegroundColor Gray
        Write-Host "  Остановить: docker-compose stop" -ForegroundColor Gray
        Write-Host "  Запустить: docker-compose start" -ForegroundColor Gray
        Write-Host "  Перезапустить: docker-compose restart" -ForegroundColor Gray
        
    } else {
        Write-Host "`nGitLab ещё не готов. Проверьте логи:" -ForegroundColor Yellow
        Write-Host "docker logs -f gitlab" -ForegroundColor Gray
    }
    
} else {
    Write-Host "`nОшибка при запуске GitLab!" -ForegroundColor Red
    Write-Host "Проверьте логи: docker logs gitlab" -ForegroundColor Yellow
    exit 1
}
