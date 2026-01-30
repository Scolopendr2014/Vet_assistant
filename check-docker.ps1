# Скрипт для проверки работы Docker после включения виртуализации

Write-Host "=== Проверка Docker ===" -ForegroundColor Green
Write-Host ""

# Проверка версии Docker
Write-Host "1. Проверка версии Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = & docker --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✓ Docker установлен: $dockerVersion" -ForegroundColor Green
    } else {
        Write-Host "   ✗ Docker не работает!" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "   ✗ Docker не найден!" -ForegroundColor Red
    Write-Host "   Убедитесь, что Docker Desktop запущен" -ForegroundColor Yellow
    exit 1
}

# Проверка версии Docker Compose
Write-Host ""
Write-Host "2. Проверка Docker Compose..." -ForegroundColor Yellow
try {
    $composeVersion = & docker-compose --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✓ Docker Compose установлен: $composeVersion" -ForegroundColor Green
    } else {
        Write-Host "   ⚠ Docker Compose не найден (может использоваться встроенный)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ⚠ Docker Compose не найден" -ForegroundColor Yellow
}

# Проверка запущенных контейнеров
Write-Host ""
Write-Host "3. Проверка запущенных контейнеров..." -ForegroundColor Yellow
try {
    $containers = & docker ps 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✓ Docker работает корректно" -ForegroundColor Green
        if ($containers -match "CONTAINER") {
            Write-Host "   Запущенные контейнеры:" -ForegroundColor Cyan
            Write-Host $containers
        } else {
            Write-Host "   Нет запущенных контейнеров (это нормально)" -ForegroundColor Gray
        }
    } else {
        Write-Host "   ✗ Ошибка при проверке контейнеров" -ForegroundColor Red
        Write-Host $containers
        exit 1
    }
} catch {
    Write-Host "   ✗ Ошибка при проверке контейнеров" -ForegroundColor Red
    exit 1
}

# Тест запуска простого контейнера
Write-Host ""
Write-Host "4. Тест запуска контейнера..." -ForegroundColor Yellow
try {
    $testResult = & docker run --rm hello-world 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✓ Тестовый контейнер запустился успешно!" -ForegroundColor Green
        Write-Host "   Виртуализация работает корректно" -ForegroundColor Green
    } else {
        Write-Host "   ✗ Не удалось запустить тестовый контейнер" -ForegroundColor Red
        Write-Host $testResult
        exit 1
    }
} catch {
    Write-Host "   ✗ Ошибка при запуске тестового контейнера" -ForegroundColor Red
    Write-Host $_.Exception.Message
    exit 1
}

Write-Host ""
Write-Host "=== Все проверки пройдены успешно! ===" -ForegroundColor Green
Write-Host ""
Write-Host "Docker готов к работе. Следующие шаги:" -ForegroundColor Cyan
Write-Host "1. Запустите GitLab: docker-compose up -d" -ForegroundColor White
Write-Host "2. Или используйте скрипт: .\.gitlab\docker-setup.ps1" -ForegroundColor White
Write-Host ""
