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
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0menu.ps1"

pause
