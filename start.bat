@echo off
title Optimization Tool - Launcher

:: --- Check administrator privileges ---
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo.
    echo  Requesting administrator privileges...
    echo.
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

:: --- Launch main PowerShell menu ---
:: Modern menu (config.json: UIMode = Modern) runs on PowerShell 7 when it is installed;
:: otherwise Windows PowerShell 5.1 is used (menu.ps1 handles the PS7 install / fallback itself).
cd /d "%~dp0"
set "PSEXE=powershell"
if exist "%~dp0config.json" (
    findstr /i /r /c:"UIMode.*Modern" "%~dp0config.json" >nul 2>&1
    if not errorlevel 1 (
        where pwsh >nul 2>&1
        if not errorlevel 1 set "PSEXE=pwsh"
    )
)
%PSEXE% -NoProfile -ExecutionPolicy Bypass -File "%~dp0menu.ps1"

:: exit code 77 = menu was reopened in Windows Terminal, close this window
if %errorlevel%==77 exit
pause
