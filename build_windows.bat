@echo off
REM Construiește TraderNote pe Windows: executabil + (dacă ai Inno Setup) installer.
REM Rulează-l din folderul proiectului:  build_windows.bat
setlocal
where python >nul 2>nul || (echo Python nu este instalat sau nu e in PATH. Instaleaza-l de pe python.org si bifeaza "Add to PATH". & exit /b 1)
if not exist .venv ( python -m venv .venv )
call .venv\Scripts\activate.bat
python -m pip install --upgrade pip
pip install -r requirements-dev.txt || exit /b 1
python -m pytest -q
python build_exe.py || exit /b 1
where iscc >nul 2>nul && ( iscc installer.iss ) || echo [info] Inno Setup (iscc) nu e instalat: sar peste installer. Executabilul e in dist\TraderNote\
echo.
echo Gata. Executabil: dist\TraderNote\TraderNote.exe
if exist dist\installer\TraderNote-Setup.exe echo Installer:  dist\installer\TraderNote-Setup.exe
endlocal
