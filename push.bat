@echo off
cd /d "%~dp0"
echo Bezig met synchroniseren van je script en assets naar GitHub...
git add .
git commit -m "Automatische update van script en assets"
git push
echo Synchronisatie voltooid!
timeout /t 5