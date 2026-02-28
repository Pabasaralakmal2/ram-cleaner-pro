@echo off
title RAM Cleaner Pro - Installation
color 0A
mode con: cols=70 lines=20

echo ╔══════════════════════════════════════════════════════════╗
echo ║              RAM CLEANER PRO - INSTALLATION              ║
echo ╚══════════════════════════════════════════════════════════╝
echo.

:: Check for administrator privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ⚠️  Administrator privileges required!
    echo.
    echo Please run this installer as Administrator.
    echo Right-click and select "Run as administrator"
    echo.
    pause
    exit /b 1
)

echo [✓] Administrator privileges confirmed
echo.

:: Create installation directory
set "installDir=%ProgramFiles%\RAM Cleaner Pro"
if not exist "%installDir%" mkdir "%installDir%"

echo Installing to: %installDir%
echo.

:: Copy main files
copy "main.bat" "%installDir%\RAMCleaner.bat" >nul
echo [✓] Main program installed

:: Create desktop shortcut
set "shortcutPath=%USERPROFILE%\Desktop\RAM Cleaner Pro.lnk"
powershell -Command "$WS = New-Object -ComObject WScript.Shell; $SC = $WS.CreateShortcut('%shortcutPath%'); $SC.TargetPath = '%installDir%\RAMCleaner.bat'; $SC.IconLocation = '%%SystemRoot%%\System32\SHELL32.dll,43'; $SC.Save()"
echo [✓] Desktop shortcut created

:: Create start menu shortcut
set "startMenu=%APPDATA%\Microsoft\Windows\Start Menu\Programs\RAM Cleaner Pro.lnk"
powershell -Command "$WS = New-Object -ComObject WScript.Shell; $SC = $WS.CreateShortcut('%startMenu%'); $SC.TargetPath = '%installDir%\RAMCleaner.bat'; $SC.IconLocation = '%%SystemRoot%%\System32\SHELL32.dll,43'; $SC.Save()"
echo [✓] Start menu shortcut created

echo.
echo ╔══════════════════════════════════════════════════════════╗
echo ║                 INSTALLATION COMPLETE!                   ║
echo ╠══════════════════════════════════════════════════════════╣
echo ║                                                          ║
echo ║   RAM Cleaner Pro has been successfully installed!      ║
echo ║                                                          ║
echo ║   You can now run it from:                              ║
echo ║   - Desktop shortcut                                    ║
echo ║   - Start Menu                                          ║
echo ║   - Command: RAMCleaner                                 ║
echo ║                                                          ║
echo ╚══════════════════════════════════════════════════════════╝
echo.
pause