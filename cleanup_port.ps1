# Cleanup port 62597 for Flutter web development
Get-NetTCPConnection -LocalPort 62597 -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Write-Host "Port 62597 cleaned up - ready for flutter run"
flutter run -d chrome --web-port 62597