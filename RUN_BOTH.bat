@echo off
echo ========================================
echo   VOGUE AI - Run Flutter App + Admin Panel
echo ========================================
echo.

echo Starting Flutter App...
start "Flutter App" cmd /k "cd /d %~dp0 && flutter pub get && flutter run"

timeout /t 3 /nobreak >nul

echo Starting Admin Panel...
start "Admin Panel" cmd /k "cd /d %~dp0admin-panel && npm install && npm start"

echo.
echo ========================================
echo   Both applications are starting...
echo ========================================
echo.
echo Flutter App will open in a new window
echo Admin Panel will open at http://localhost:3000
echo.
echo Press any key to exit this window (apps will keep running)
pause >nul

