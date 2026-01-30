# Простой скрипт для открытия wsl.conf

Write-Host "=== Открытие wsl.conf ===" -ForegroundColor Green
Write-Host ""

# Проверка, находимся ли мы в PowerShell
if ($PSVersionTable) {
    Write-Host "Вы находитесь в PowerShell Windows" -ForegroundColor Cyan
    Write-Host ""
    
    # Проверка WSL
    Write-Host "Проверка WSL..." -ForegroundColor Yellow
    try {
        $wslList = wsl --list --verbose 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "WSL установлен:" -ForegroundColor Green
            Write-Host $wslList
            Write-Host ""
            
            Write-Host "Попытка открыть wsl.conf..." -ForegroundColor Yellow
            Write-Host ""
            Write-Host "Вариант 1: Войти в WSL и открыть файл" -ForegroundColor Cyan
            Write-Host "  Выполните: wsl" -ForegroundColor White
            Write-Host "  Затем: sudo nano /etc/wsl.conf" -ForegroundColor White
            Write-Host ""
            
            Write-Host "Вариант 2: Открыть напрямую из PowerShell" -ForegroundColor Cyan
            Write-Host "  Выполните: wsl sudo nano /etc/wsl.conf" -ForegroundColor White
            Write-Host ""
            
            Write-Host "Вариант 3: Скопировать в Windows для редактирования" -ForegroundColor Cyan
            Write-Host "  Выполните следующие команды:" -ForegroundColor White
            Write-Host "    wsl cat /etc/wsl.conf > `$env:TEMP\wsl.conf" -ForegroundColor Gray
            Write-Host "    notepad `$env:TEMP\wsl.conf" -ForegroundColor Gray
            Write-Host "    wsl sudo cp `$env:TEMP\wsl.conf /etc/wsl.conf" -ForegroundColor Gray
            Write-Host ""
            
            # Попытка автоматически открыть
            Write-Host "Попытка автоматически открыть файл..." -ForegroundColor Yellow
            $tempFile = "$env:TEMP\wsl.conf"
            
            # Копируем файл
            $copyResult = wsl cat /etc/wsl.conf 2>&1
            if ($LASTEXITCODE -eq 0 -and $copyResult) {
                $copyResult | Out-File -FilePath $tempFile -Encoding UTF8
                Write-Host "✓ Файл скопирован в: $tempFile" -ForegroundColor Green
                Write-Host ""
                Write-Host "Открываю файл в редакторе..." -ForegroundColor Yellow
                Start-Process notepad.exe $tempFile
                Write-Host ""
                Write-Host "После редактирования скопируйте обратно:" -ForegroundColor Cyan
                Write-Host "  wsl sudo cp `"$tempFile`" /etc/wsl.conf" -ForegroundColor White
            } else {
                Write-Host "⚠ Файл /etc/wsl.conf не существует" -ForegroundColor Yellow
                Write-Host ""
                Write-Host "Создаю шаблон файла..." -ForegroundColor Yellow
                $template = @"
# WSL configuration file
[boot]
# systemd = true

[network]
generateHosts = true
generateResolvConf = true

[interop]
enabled = true
appendWindowsPath = true

[automount]
enabled = true
root = /mnt/
options = "metadata,umask=22,fmask=11"
mountFsTab = true
"@
                $template | Out-File -FilePath $tempFile -Encoding UTF8
                Write-Host "✓ Создан шаблон: $tempFile" -ForegroundColor Green
                Write-Host ""
                Write-Host "Открываю файл для редактирования..." -ForegroundColor Yellow
                Start-Process notepad.exe $tempFile
                Write-Host ""
                Write-Host "После редактирования скопируйте в WSL:" -ForegroundColor Cyan
                Write-Host "  wsl sudo cp `"$tempFile`" /etc/wsl.conf" -ForegroundColor White
            }
        } else {
            Write-Host "⚠ WSL не установлен или не настроен" -ForegroundColor Red
            Write-Host ""
            Write-Host "Для установки WSL выполните (от имени администратора):" -ForegroundColor Yellow
            Write-Host "  wsl --install" -ForegroundColor White
        }
    } catch {
        Write-Host "⚠ Ошибка при проверке WSL: $_" -ForegroundColor Red
    }
} else {
    Write-Host "Вы находитесь в WSL/Linux" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Выполните команду напрямую (без wsl):" -ForegroundColor Yellow
    Write-Host "  sudo nano /etc/wsl.conf" -ForegroundColor White
    Write-Host ""
    Write-Host "Или если sudo не работает:" -ForegroundColor Yellow
    Write-Host "  nano /etc/wsl.conf" -ForegroundColor White
}

Write-Host ""
