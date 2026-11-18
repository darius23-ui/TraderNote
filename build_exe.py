"""
Construiește un executabil de sine stătător (fără Python instalat).

    pip install -r requirements-dev.txt
    python build_exe.py

Rezultat:  dist/TraderNote/TraderNote(.exe)   (folder; copiază-l unde vrei)
PyInstaller construiește pentru sistemul pe care rulează: pentru .exe rulează scriptul pe Windows
(sau folosește workflow-ul GitHub din .github/workflows/build-windows.yml, care o face fără Windows local).

Date: aplicația instalată își ține datele în %APPDATA%\\TraderNote. Pentru mod portabil pune un fișier gol
`portable.txt` (sau un `tradernote.db` existent) lângă executabil: datele se vor crea lângă el.
"""
import os
import subprocess
import sys

ROOT = os.path.dirname(os.path.abspath(__file__))
SEP = ";" if sys.platform.startswith("win") else ":"

cmd = [
    sys.executable, "-m", "PyInstaller", "--noconfirm", "--clean", "--windowed",
    "--name", "TraderNote",
    "--icon", os.path.join(ROOT, "assets", "icon.ico"),
    "--add-data", f"{os.path.join(ROOT, 'assets')}{SEP}assets",
    "--collect-all", "customtkinter",          # teme, fonturi și imagini ale CustomTkinter
    "--collect-all", "yfinance",
    "--collect-all", "curl_cffi",              # clientul HTTP folosit de yfinance
    "--collect-data", "certifi",
    "--collect-submodules", "pystray",         # pictograma din system tray (opțională)
    "--hidden-import", "PIL._tkinter_finder",  # necesar pentru ImageTk (graficele) în aplicația împachetată
    "--hidden-import", "pandas",
    "--hidden-import", "openpyxl",
]
if sys.platform.startswith("win"):
    cmd += ["--hidden-import", "pystray._win32", "--hidden-import", "winreg"]
cmd.append(os.path.join(ROOT, "run.py"))
print(" ".join(cmd))
sys.exit(subprocess.call(cmd, cwd=ROOT))
