# Проверка настройки Git и подключения к GitLab.com
# Запуск: из корня проекта: .\.gitlab\check-git-setup.ps1

Write-Host "=== Проверка настройки Git и GitLab.com ===" -ForegroundColor Green
Write-Host ""

# 1. Git установлен?
Write-Host "1. Git:" -ForegroundColor Yellow
try {
    $v = git --version
    Write-Host "   OK - $v" -ForegroundColor Green
} catch {
    Write-Host "   Ошибка: Git не найден. Установите: https://git-scm.com/download/win" -ForegroundColor Red
    exit 1
}

# 2. Имя и email
Write-Host "`n2. Глобальная конфигурация:" -ForegroundColor Yellow
$name = git config --global user.name 2>$null
$email = git config --global user.email 2>$null
if ($name) { Write-Host "   user.name  = $name" -ForegroundColor Green } else { Write-Host "   user.name  не задан" -ForegroundColor Red }
if ($email) { Write-Host "   user.email = $email" -ForegroundColor Green } else { Write-Host "   user.email не задан" -ForegroundColor Red }

# 3. Репозиторий и remote
Write-Host "`n3. Репозиторий и remote:" -ForegroundColor Yellow
$gitDir = Join-Path $PSScriptRoot ".." ".git"
if (Test-Path (Join-Path $gitDir "config")) {
    Write-Host "   Репозиторий инициализирован (.git есть)" -ForegroundColor Green
    Write-Host "   Remote origin:" -ForegroundColor Gray
    git remote -v 2>$null
    $url = git config --get remote.origin.url 2>$null
    if ($url -match "scolopendr/vet-assistant") {
        Write-Host "   OK - URL указывает на GitLab.com (scolopendr/vet-assistant)" -ForegroundColor Green
    } elseif ($url -match "ВАШ_USERNAME|ИМЯ_ПРОЕКТА") {
        Write-Host "   Ошибка: в URL остались плейсхолдеры. Выполните:" -ForegroundColor Red
        Write-Host "   git remote set-url origin https://gitlab.com/scolopendr/vet-assistant.git" -ForegroundColor Gray
    } else {
        Write-Host "   URL: $url" -ForegroundColor Gray
    }
} else {
    Write-Host "   Репозиторий не инициализирован (нет .git). Выполните: git init" -ForegroundColor Yellow
}

Write-Host "`n--- Готово ---" -ForegroundColor Cyan
Write-Host "Для первого push: git add . ; git commit -m 'Initial commit' ; git push -u origin main" -ForegroundColor Gray
