@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo FAVV Assistent wordt gecontroleerd...
findstr /C:"data-page=\"actions\"" index.html >nul || goto fout
findstr /C:"function renderTemperatureActions" index.html >nul || goto fout
findstr /C:"function renderSubscription" index.html >nul || goto fout
findstr /C:"function renderStock" index.html >nul || goto fout
findstr /C:"function renderRecipes" index.html >nul || goto fout
echo.
echo CONTROLE GESLAAGD.
echo De werkende hoofdonderdelen zijn aanwezig.
pause
exit /b 0
:fout
echo.
echo FOUT: een belangrijk onderdeel ontbreekt.
echo Gebruik WERKENDE_APP_RESERVEKOPIE.html als veilige kopie.
pause
exit /b 1
