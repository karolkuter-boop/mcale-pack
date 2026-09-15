@echo off
setlocal EnableExtensions DisableDelayedExpansion
powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "%~dp0packwiz-update.ps1"
exit /b %ERRORLEVEL%
