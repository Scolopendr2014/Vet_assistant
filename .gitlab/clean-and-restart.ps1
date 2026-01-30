# Полная очистка данных GitLab и перезапуск (при ошибках PostgreSQL / "base/1 is not a valid data directory")
# Запуск: из корня проекта: .\.gitlab\clean-and-restart.ps1

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path $PSScriptRoot -Parent
if (-not (Test-Path (Join-Path $projectRoot "docker-compose.yml"))) {
    $projectRoot = (Get-Location).Path
}
Set-Location $projectRoot

Write-Host "=== Очистка данных GitLab и перезапуск ===" -ForegroundColor Green
Write-Host "Папка проекта: $projectRoot" -ForegroundColor Gray
Write-Host ""

Write-Host "1. Останавливаем контейнеры..." -ForegroundColor Yellow
docker-compose down 2>$null
Write-Host "   Готово." -ForegroundColor Green

Write-Host "`n2. Удаляем папки с данными (data, config, logs)..." -ForegroundColor Yellow
$folders = @("gitlab\data", "gitlab\config", "gitlab\logs")
foreach ($f in $folders) {
    $path = Join-Path $projectRoot $f
    if (Test-Path $path) {
        Remove-Item -Recurse -Force $path
        Write-Host "   Удалено: $f" -ForegroundColor Gray
    }
}

Write-Host "`n3. Создаём пустые папки..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path (Join-Path $projectRoot "gitlab\data") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $projectRoot "gitlab\config") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $projectRoot "gitlab\logs") | Out-Null
Write-Host "   Готово." -ForegroundColor Green

Write-Host "`n4. Запускаем GitLab..." -ForegroundColor Yellow
docker-compose up -d
if ($LASTEXITCODE -ne 0) {
    Write-Host "Ошибка при запуске." -ForegroundColor Red
    exit 1
}

Write-Host "`n=== Готово ===" -ForegroundColor Green
Write-Host "Подождите 15–20 минут. Логи: docker logs -f gitlab" -ForegroundColor Cyan
Write-Host "Когда в логах появится 'GitLab is ready', откройте http://localhost:8080" -ForegroundColor Cyan
