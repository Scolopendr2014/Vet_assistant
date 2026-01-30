# Диагностика: почему http://localhost открывает пустую страницу
Write-Host "=== Проверка GitLab ===" -ForegroundColor Green

Write-Host "`n1. Контейнеры проекта:" -ForegroundColor Yellow
docker ps -a --filter "name=gitlab" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

Write-Host "`n2. Последние 40 строк логов (ищем 'ready' или ошибки):" -ForegroundColor Yellow
docker logs --tail 40 gitlab 2>&1

Write-Host "`n3. Порт 80 (если пусто - порт свободен):" -ForegroundColor Yellow
netstat -ano | findstr ":80 "

Write-Host "`n--- Рекомендации ---" -ForegroundColor Cyan
Write-Host "Если контейнер Up меньше 10-15 минут - подождите, GitLab долго стартует." -ForegroundColor Gray
Write-Host "Когда в логах появится 'GitLab is ready' - обновите http://localhost (Ctrl+F5)" -ForegroundColor Gray
Write-Host "Логи в реальном времени: docker logs -f gitlab" -ForegroundColor Gray
