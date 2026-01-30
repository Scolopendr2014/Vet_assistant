# Скрипт для проверки WSL и открытия wsl.conf

Write-Host "=== Проверка WSL ===" -ForegroundColor Green
Write-Host ""

# Проверка установленных WSL дистрибутивов
Write-Host "Установленные WSL дистрибутивы:" -ForegroundColor Yellow
wsl --list --verbose
Write-Host ""

# Попытка определить дистрибутив по умолчанию
Write-Host "Попытка открыть wsl.conf..." -ForegroundColor Yellow
Write-Host ""

# Вариант 1: Попробовать с sudo
Write-Host "Вариант 1: Попытка открыть через sudo..." -ForegroundColor Cyan
try {
    wsl sudo nano /etc/wsl.conf
} catch {
    Write-Host "Ошибка с sudo. Пробуем другие варианты..." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Если sudo не работает, попробуйте:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Войти в WSL и выполнить команды там:" -ForegroundColor White
Write-Host "   wsl" -ForegroundColor Gray
Write-Host "   sudo nano /etc/wsl.conf" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Или если вы root, попробуйте без sudo:" -ForegroundColor White
Write-Host "   wsl nano /etc/wsl.conf" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Или скопировать файл в Windows для редактирования:" -ForegroundColor White
Write-Host "   wsl cat /etc/wsl.conf > `$env:TEMP\wsl.conf" -ForegroundColor Gray
Write-Host "   notepad `$env:TEMP\wsl.conf" -ForegroundColor Gray
Write-Host ""
