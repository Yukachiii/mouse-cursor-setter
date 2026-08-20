@echo off
setlocal EnableExtensions
title Cursor Scheme Installer

if "%~1"=="" (
    echo Drag and drop a folder containing ANI/CUR files onto this BAT file.
    echo.
    pause
    exit /b 1
)

set "CURSOR_DIR=%~f1"
set "SCHEME_NAME=%~nx1"

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0CursorSchemeInstaller.ps1"
set "RC=%ERRORLEVEL%"

if not "%RC%"=="0" (
    echo.
    echo Installation failed. Error code: %RC%
    echo.
    pause
)

exit /b %RC%
