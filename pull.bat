@echo off
cd /d "%~dp0"
echo Bezig met ophalen van je wijzigingen...
git pull
echo.
echo Synchronisatie voltooid!
timeout /t 5