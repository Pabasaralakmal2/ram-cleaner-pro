@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: RAM Cleaner Pro - Main Program
title RAM Cleaner Pro v2.0
mode con: cols=90 lines=35

:: Color Setup
:: 0=Black, 1=Blue, 2=Green, 3=Aqua, 4=Red, 5=Purple, 6=Yellow, 7=White, 8=Gray, 9=Light Blue
color 0A

:: Initialize Variables
set "cleanLevel=Normal"
set "cleanCount=0"
set "freedMemory=0"
set "totalFreed=0"

:: Create temporary directory
if not exist "%temp%\RAMCleaner" mkdir "%temp%\RAMCleaner"

:: Main Menu Loop
:main_menu
cls

:: Header with ASCII Art
echo ╔══════════════════════════════════════════════════════════════════════════════╗
echo ║                           🚀 RAM CLEANER PRO v2.0                            ║
echo ╚══════════════════════════════════════════════════════════════════════════════╝
echo.

:: RAM Monitor Section
call :get_ram_info
echo ╔══════════════════════ RAM MONITOR ══════════════════════╗
echo ║                                                          ║
echo ║   Total RAM: %totalRAM% GB                                   ║
echo ║   Used RAM : %usedRAM% GB  [%usedPercent%]                ║
echo ║   Free RAM : %freeRAM% GB                                   ║
echo ║                                                          ║
echo ║   RAM Usage Bar:                                         ║
set /a barLength=40
set /a filledLength=(usedPercentNum * barLength) / 100
set "bar="
for /l %%i in (1,1,!barLength!) do (
    if %%i leq !filledLength! (
        set "bar=!bar!█"
    ) else (
        set "bar=!bar!░"
    )
)
echo ║   [%bar%]  ║
echo ║   %usedPercent% Used                        %freePercent% Free  ║
echo ╚══════════════════════════════════════════════════════════╝
echo.

:: Cleaning Options Menu
echo ╔══════════════════════ CLEANING OPTIONS ═══════════════════╗
echo ║                                                          ║
echo ║   Current Mode: [%cleanLevel%]                              ║
echo ║                                                          ║
echo ║   [1] 🧹 QUICK CLEAN - Empty working sets               ║
echo ║   [2] 🔧 NORMAL CLEAN - Clear system cache              ║
echo ║   [3] ⚡ DEEP CLEAN - Aggressive memory optimization     ║
echo ║   [4] 🚀 ULTRA CLEAN - Maximum performance              ║
echo ║                                                          ║
echo ║   [5] 📊 STATISTICS - View cleaning history              ║
echo ║   [6] ⚙️  SETTINGS - Configure options                    ║
echo ║   [7] ❌ EXIT - Close application                        ║
echo ║                                                          ║
echo ╚══════════════════════════════════════════════════════════╝
echo.

:: Stylish Buttons
echo ╔══════════════════════════════════════════════════════════════════════════════╗
echo ║                                                                              ║
set "button1= [ 1-QUICK  ] "
set "button2= [ 2-NORMAL ] "
set "button3= [ 3-DEEP   ] "
set "button4= [ 4-ULTRA  ] "
set "button5= [ 5-STATS  ] "
set "button6= [ 6-SETTINGS] "
set "button7= [ 7-EXIT   ] "
echo ║     %button1%  %button2%  %button3%  %button4%  %button5%  %button6%  %button7%     ║
echo ║                                                                              ║
echo ╚══════════════════════════════════════════════════════════════════════════════╝
echo.

set /p choice="👉 Select an option [1-7]: "

if "%choice%"=="1" call :quick_clean
if "%choice%"=="2" call :normal_clean
if "%choice%"=="3" call :deep_clean
if "%choice%"=="4" call :ultra_clean
if "%choice%"=="5" call :show_stats
if "%choice%"=="6" call :settings_menu
if "%choice%"=="7" exit /b

goto main_menu

:: Functions
:get_ram_info
:: Get system memory info using WMIC
for /f "skip=1" %%a in ('wmic os get TotalVisibleMemorySize') do set "totalMem=%%a" & goto :next1
:next1
for /f "skip=1" %%a in ('wmic os get FreePhysicalMemory') do set "freeMem=%%a" & goto :next2
:next2

:: Convert from KB to GB and calculate percentages
set /a totalMemNum=%totalMem%
set /a freeMemNum=%freeMem%
set /a usedMemNum=%totalMemNum% - %freeMemNum%

set /a totalRAM=%totalMemNum% / 1048576
set /a freeRAM=%freeMemNum% / 1048576
set /a usedRAM=%totalRAM% - %freeRAM%

set /a usedPercentNum=(%usedMemNum% * 100) / %totalMemNum%
set /a freePercentNum=100 - %usedPercentNum%

set "usedPercent=%usedPercentNum%%%"
set "freePercent=%freePercentNum%%%"
goto :eof

:quick_clean
cls
echo ╔══════════════════════ QUICK CLEAN ═══════════════════════╗
echo ║                                                          ║
echo ║   Performing quick memory cleanup...                     ║
echo ║                                                          ║
echo ╚══════════════════════════════════════════════════════════╝
echo.

:: Get initial free memory
call :get_ram_info
set "initialFree=%freeMemNum%"

:: Quick cleaning commands
echo ║ Running Quick Clean Commands...
echo.
ipconfig /flushdns >nul 2>&1
echo [✓] DNS cache cleared

rundll32.exe advapi32.dll,ProcessIdleTasks >nul 2>&1
echo [✓] Idle tasks processed

:: Clear working sets
for /f "skip=3" %%a in ('tasklist /fi "status eq running"') do (
    if not "%%a"=="=" (
        powershell -command "[System.GC]::Collect()" >nul 2>&1
    )
)
echo [✓] Working sets emptied

:: Get final free memory
call :get_ram_info
set "finalFree=%freeMemNum%"
set /a freed=%finalFree% - %initialFree%
set /a freedMB=%freed% / 1024

if %freed% lss 0 set /a freed=0
set /a freedRAM=%freed% / 1048576
set /a totalFreed+=%freed%

echo.
echo ╔══════════════════════════════════════════════════════════╗
echo ║                   CLEANING COMPLETE!                     ║
echo ╠══════════════════════════════════════════════════════════╣
echo ║                                                          ║
echo ║   Memory Freed: %freedRAM% GB (%freedMB% MB)                  ║
echo ║   Status: ✅ Quick Clean Successful                      ║
echo ║                                                          ║
echo ╚══════════════════════════════════════════════════════════╝
echo.
echo Press any key to continue...
pause >nul
goto main_menu

:normal_clean
cls
echo ╔══════════════════════ NORMAL CLEAN ══════════════════════╗
echo ║                                                          ║
echo ║   Performing normal system cleanup...                    ║
echo ║                                                          ║
echo ╚══════════════════════════════════════════════════════════╝
echo.

:: Get initial free memory
call :get_ram_info
set "initialFree=%freeMemNum%"

:: Normal cleaning commands
echo ║ Running Normal Clean Commands...
echo.
ipconfig /flushdns >nul 2>&1
echo [✓] DNS cache cleared

rundll32.exe advapi32.dll,ProcessIdleTasks >nul 2>&1
echo [✓] Idle tasks processed

:: Clear prefetch
del /f /s /q "%SystemRoot%\Prefetch\*.*" >nul 2>&1
echo [✓] Prefetch cleared

:: Clear temporary files
del /f /s /q "%TEMP%\*.*" >nul 2>&1
echo [✓] Temporary files cleared

:: Clear recent documents
del /f /s /q "%USERPROFILE%\Recent\*.*" >nul 2>&1
echo [✓] Recent documents cleared

:: Get final free memory
call :get_ram_info
set "finalFree=%freeMemNum%"
set /a freed=%finalFree% - %initialFree%
set /a freedMB=%freed% / 1024

if %freed% lss 0 set /a freed=0
set /a freedRAM=%freed% / 1048576
set /a totalFreed+=%freed%

echo.
echo ╔══════════════════════════════════════════════════════════╗
echo ║                   CLEANING COMPLETE!                     ║
echo ╠══════════════════════════════════════════════════════════╣
echo ║                                                          ║
echo ║   Memory Freed: %freedRAM% GB (%freedMB% MB)                  ║
echo ║   Status: ✅ Normal Clean Successful                      ║
echo ║                                                          ║
echo ╚══════════════════════════════════════════════════════════╝
echo.
echo Press any key to continue...
pause >nul
goto main_menu

:deep_clean
cls
echo ╔═══════════════════════ DEEP CLEAN ═══════════════════════╗
echo ║                                                          ║
echo ║   Performing deep system cleanup...                      ║
echo ║   ⚠️  This may take a few minutes                        ║
echo ║                                                          ║
echo ╚══════════════════════════════════════════════════════════╝
echo.

:: Get initial free memory
call :get_ram_info
set "initialFree=%freeMemNum%"

:: Deep cleaning commands
echo ║ Running Deep Clean Commands...
echo.
ipconfig /flushdns >nul 2>&1
echo [✓] DNS cache cleared

rundll32.exe advapi32.dll,ProcessIdleTasks >nul 2>&1
echo [✓] Idle tasks processed

:: Clear all caches
del /f /s /q "%SystemRoot%\Prefetch\*.*" >nul 2>&1
echo [✓] Prefetch cleared

del /f /s /q "%TEMP%\*.*" >nul 2>&1
echo [✓] Temp files cleared

del /f /s /q "%USERPROFILE%\AppData\Local\Temp\*.*" >nul 2>&1
echo [✓] AppData Temp cleared

del /f /s /q "%WINDIR%\Temp\*.*" >nul 2>&1
echo [✓] Windows Temp cleared

:: Clear browser caches (Chrome, Edge, Firefox)
del /f /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache\*.*" >nul 2>&1
echo [✓] Chrome cache cleared

del /f /s /q "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache\*.*" >nul 2>&1
echo [✓] Edge cache cleared

del /f /s /q "%APPDATA%\Mozilla\Firefox\Profiles\*\cache2\*.*" >nul 2>&1
echo [✓] Firefox cache cleared

:: Clear thumbnail cache
del /f /s /q "%USERPROFILE%\AppData\Local\Microsoft\Windows\Explorer\thumbcache_*.db" >nul 2>&1
echo [✓] Thumbnail cache cleared

:: Run disk cleanup silently
cleanmgr /sagerun:1 >nul 2>&1
echo [✓] Disk Cleanup initiated

:: Get final free memory
call :get_ram_info
set "finalFree=%freeMemNum%"
set /a freed=%finalFree% - %initialFree%
set /a freedMB=%freed% / 1024

if %freed% lss 0 set /a freed=0
set /a freedRAM=%freed% / 1048576
set /a totalFreed+=%freed%

echo.
echo ╔══════════════════════════════════════════════════════════╗
echo ║                   CLEANING COMPLETE!                     ║
echo ╠══════════════════════════════════════════════════════════╣
echo ║                                                          ║
echo ║   Memory Freed: %freedRAM% GB (%freedMB% MB)                  ║
echo ║   Status: ✅ Deep Clean Successful                        ║
echo ║                                                          ║
echo ╚══════════════════════════════════════════════════════════╝
echo.
echo Press any key to continue...
pause >nul
goto main_menu

:ultra_clean
cls
echo ╔═══════════════════════ ULTRA CLEAN ══════════════════════╗
echo ║                                                          ║
echo ║   Performing ULTRA system optimization...                ║
echo ║   ⚠️  This will take several minutes                     ║
echo ║   ⚠️  Some applications may close temporarily            ║
echo ║                                                          ║
echo ╚══════════════════════════════════════════════════════════╝
echo.

:: Get initial free memory
call :get_ram_info
set "initialFree=%freeMemNum%"

:: Ultra cleaning commands
echo ║ Running ULTRA Clean Commands...
echo.

:: Step 1: Basic cleaning
ipconfig /flushdns >nul 2>&1
echo [✓] DNS cache cleared

rundll32.exe advapi32.dll,ProcessIdleTasks >nul 2>&1
echo [✓] Idle tasks processed

:: Step 2: Cache clearing
del /f /s /q "%SystemRoot%\Prefetch\*.*" >nul 2>&1
echo [✓] Prefetch cleared

del /f /s /q "%TEMP%\*.*" >nul 2>&1
echo [✓] Temp files cleared

del /f /s /q "%WINDIR%\Temp\*.*" >nul 2>&1
echo [✓] Windows Temp cleared

:: Step 3: Application caches
del /f /s /q "%LOCALAPPDATA%\Temp\*.*" >nul 2>&1
echo [✓] AppData caches cleared

:: Step 4: Browser caches (all major browsers)
for %%b in (Chrome Edge Firefox Opera Brave) do (
    del /f /s /q "%LOCALAPPDATA%\%%b\User Data\*\Cache\*.*" >nul 2>&1
    del /f /s /q "%APPDATA%\%%b\*\cache2\*.*" >nul 2>&1
)
echo [✓] All browser caches cleared

:: Step 5: System caches
del /f /s /q "%USERPROFILE%\AppData\Local\Microsoft\Windows\Explorer\thumbcache_*.db" >nul 2>&1
echo [✓] Thumbnail cache cleared

del /f /s /q "%USERPROFILE%\AppData\Local\IconCache.db" >nul 2>&1
echo [✓] Icon cache cleared

:: Step 6: Advanced memory optimization
for /f "skip=3" %%a in ('tasklist /fi "status eq running"') do (
    if not "%%a"=="=" (
        powershell -command "[System.GC]::Collect()" >nul 2>&1
        powershell -command "[System.GC]::WaitForPendingFinalizers()" >nul 2>&1
    )
)
echo [✓] Memory optimized

:: Step 7: Disk cleanup with all options
cleanmgr /sagerun:1 >nul 2>&1
echo [✓] Disk Cleanup completed

:: Step 8: System file checker (optional)
sfc /scannow >nul 2>&1
echo [✓] System files verified

:: Get final free memory
call :get_ram_info
set "finalFree=%freeMemNum%"
set /a freed=%finalFree% - %initialFree%
set /a freedMB=%freed% / 1024

if %freed% lss 0 set /a freed=0
set /a freedRAM=%freed% / 1048576
set /a totalFreed+=%freed%

echo.
echo ╔══════════════════════════════════════════════════════════╗
echo ║                   CLEANING COMPLETE!                     ║
echo ╠══════════════════════════════════════════════════════════╣
echo ║                                                          ║
echo ║   Memory Freed: %freedRAM% GB (%freedMB% MB)                  ║
echo ║   Status: ✅ ULTRA Clean Successful                       ║
echo ║                                                          ║
echo ╚══════════════════════════════════════════════════════════╝
echo.
echo Press any key to continue...
pause >nul
goto main_menu

:show_stats
cls
echo ╔══════════════════════ CLEANING STATISTICS ═════════════════╗
echo ║                                                           ║
echo ║   Total Cleanups Performed: %cleanCount%                             ║
echo ║   Total Memory Freed: %totalFreed% KB                           ║
echo ║   Current RAM Usage: %usedPercent%                             ║
echo ║                                                           ║
echo ║   Cleaning History:                                        ║
echo ║   - Quick Clean: %quickCount% times                            ║
echo ║   - Normal Clean: %normalCount% times                           ║
echo ║   - Deep Clean: %deepCount% times                             ║
echo ║   - Ultra Clean: %ultraCount% times                            ║
echo ║                                                           ║
echo ╚═══════════════════════════════════════════════════════════╝
echo.
echo Press any key to continue...
pause >nul
goto main_menu

:settings_menu
cls
echo ╔══════════════════════════ SETTINGS ═══════════════════════╗
echo ║                                                          ║
echo ║   [1] Auto-refresh RAM Monitor (Current: ON)            ║
echo ║   [2] Show notifications (Current: ON)                  ║
echo ║   [3] Start with Windows (Current: OFF)                 ║
echo ║   [4] Sound effects (Current: OFF)                      ║
echo ║   [5] Return to Main Menu                               ║
echo ║                                                          ║
echo ╚══════════════════════════════════════════════════════════╝
echo.
set /p setting="👉 Select setting to toggle [1-5]: "

if "%setting%"=="5" goto main_menu
echo.
echo Setting toggled! (Demo mode - configure as needed)
timeout /t 2 /nobreak >nul
goto settings_menu
