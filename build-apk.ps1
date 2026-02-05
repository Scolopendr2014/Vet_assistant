# Сборка APK и копирование в dist/
Set-Location $PSScriptRoot

Write-Host "Сборка APK..." -ForegroundColor Cyan
flutter build apk

if ($LASTEXITCODE -eq 0) {
    New-Item -ItemType Directory -Force -Path "dist" | Out-Null
    $source = "build\app\outputs\flutter-apk\app-release.apk"
    if (-not (Test-Path $source)) {
        $source = "build\app\outputs\flutter-apk\app-debug.apk"
    }
    $dest = "dist\vet_assistant-$(Get-Date -Format 'yyyyMMdd-HHmm').apk"
    Copy-Item $source -Destination $dest -Force
    Write-Host "`nAPK сохранён: $dest" -ForegroundColor Green
} else {
    Write-Host "Ошибка сборки" -ForegroundColor Red
    exit 1
}
