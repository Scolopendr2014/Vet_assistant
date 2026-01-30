# Скрипт для поиска и открытия wsl.conf

Write-Host "=== Поиск и открытие wsl.conf ===" -ForegroundColor Green
Write-Host ""

# Попытка прочитать файл через WSL
Write-Host "Попытка прочитать /etc/wsl.conf из WSL..." -ForegroundColor Yellow

# Получаем список WSL дистрибутивов
$distros = wsl --list --quiet 2>$null

if ($distros) {
    Write-Host "Найденные WSL дистрибутивы:" -ForegroundColor Cyan
    $distros | ForEach-Object { Write-Host "  - $_" -ForegroundColor Gray }
    Write-Host ""
    
    # Используем первый дистрибутив по умолчанию
    $defaultDistro = ($distros | Select-Object -First 1).Trim()
    
    Write-Host "Проверка файла в дистрибутиве: $defaultDistro" -ForegroundColor Yellow
    
    # Проверяем существование файла
    $fileExists = wsl -d $defaultDistro test -f /etc/wsl.conf 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Файл /etc/wsl.conf найден!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Содержимое файла:" -ForegroundColor Cyan
        Write-Host "----------------------------------------" -ForegroundColor Gray
        wsl -d $defaultDistro cat /etc/wsl.conf
        Write-Host "----------------------------------------" -ForegroundColor Gray
        Write-Host ""
        
        # Создаём временную копию для редактирования
        $tempFile = "$env:TEMP\wsl.conf"
        Write-Host "Создание временной копии для редактирования: $tempFile" -ForegroundColor Yellow
        wsl -d $defaultDistro cat /etc/wsl.conf > $tempFile
        
        Write-Host ""
        Write-Host "Файл скопирован в: $tempFile" -ForegroundColor Green
        Write-Host ""
        Write-Host "Для редактирования:" -ForegroundColor Cyan
        Write-Host "1. Откройте файл: $tempFile" -ForegroundColor White
        Write-Host "2. Внесите изменения" -ForegroundColor White
        Write-Host "3. Скопируйте обратно в WSL командой:" -ForegroundColor White
        Write-Host "   wsl -d $defaultDistro sudo cp $tempFile /etc/wsl.conf" -ForegroundColor Yellow
        Write-Host ""
        
        # Открываем файл в редакторе по умолчанию
        Write-Host "Открываю файл в редакторе..." -ForegroundColor Yellow
        Start-Process notepad.exe $tempFile
        
    } else {
        Write-Host "⚠ Файл /etc/wsl.conf не существует" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Создание нового файла wsl.conf..." -ForegroundColor Yellow
        
        # Создаём шаблон файла
        $template = @"
# WSL configuration file
# This file configures the behavior of the WSL distribution

[boot]
# systemd = true

[network]
# generateHosts = true
# generateResolvConf = true

[interop]
# enabled = true
# appendWindowsPath = true

[user]
# default = username

[automount]
# enabled = true
# root = /mnt/
# options = "metadata,umask=22,fmask=11"
# mountFsTab = true

"@
        
        $tempFile = "$env:TEMP\wsl.conf"
        $template | Out-File -FilePath $tempFile -Encoding UTF8
        
        Write-Host "✓ Создан шаблон файла: $tempFile" -ForegroundColor Green
        Write-Host ""
        Write-Host "Открываю файл для редактирования..." -ForegroundColor Yellow
        Start-Process notepad.exe $tempFile
        
        Write-Host ""
        Write-Host "После редактирования скопируйте файл в WSL:" -ForegroundColor Cyan
        Write-Host "  wsl -d $defaultDistro sudo cp $tempFile /etc/wsl.conf" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Или создайте файл вручную в WSL:" -ForegroundColor Cyan
        Write-Host "  wsl -d $defaultDistro sudo nano /etc/wsl.conf" -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠ WSL не установлен или не настроен" -ForegroundColor Red
    Write-Host ""
    Write-Host "Для установки WSL выполните:" -ForegroundColor Yellow
    Write-Host "  wsl --install" -ForegroundColor White
}

Write-Host ""
