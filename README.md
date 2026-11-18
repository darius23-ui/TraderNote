# TraderNote v5

Jurnal și tracker de portofoliu (CustomTkinter): prețuri live cu impact valutar, evoluție vs benchmark, risc, import de la
brokeri, alerte care merg și cu fereastra închisă, raport anual, statistici de jurnal.

## Pornire rapidă
```
pip install -r requirements.txt
python run.py
```
Datele (`tradernote.db`, `screenshots/`, `backups/`) se află lângă `run.py`. Ca să-ți păstrezi datele din versiunile vechi,
copiază `tradernote.db` și `screenshots/` în acest folder; schema se migrează automat. Locul datelor se poate schimba cu
variabila de mediu `TRADERNOTE_HOME`.

## Noutăți în v5
| # | Funcție | Unde |
|---|---|---|
| 1 | **Dividende automate** din Yahoo: propune ce ai fi încasat (acțiuni deținute în ziua dinaintea datei ex-dividend), tu confirmi, cu % de impozit reținut | Portfolio → „Find dividends” |
| 2 | **Alerte cu fereastra închisă**: pictogramă în system tray, pornire automată la login, „Keep me signed in” | Setări → „Window & startup” |
| 3 | **Alerte pe preț și P/L**: „sub 450 RON”, stop-loss „-8%”, take-profit „+20%”; starea se reține (fără re-notificare după repornire) | Price Alerts |
| 4 | **Monedă de raportare** RON/EUR/USD/GBP/CHF, cu cursul fiecărei zile (efectul valutar face parte din rezultat) | Setări → „Reporting currency” |
| 5 | **Risc**: drawdown maxim/curent, volatilitate, beta și corelație vs benchmark, zile extreme, expunere pe activ/monedă/sector/țară/tip | Risk |
| 6 | **Statistici de jurnal**: rata de câștig, câștig mediu vs pierdere medie, profit factor, așteptare, pe „setup”; note legate de activ | Journal → Statistics |
| 7 | **XIRR** (randament ponderat cu banii, anualizat) lângă TWR, pe portofoliu și pe fiecare activ | Dashboard, pagina de activ |
| 8 | **Pachet Windows**: installer (Inno Setup), build automat pe GitHub, date în `%APPDATA%`, o singură instanță | vezi „Windows” |

Din v4 rămân: grafic de evoluție cu benchmark (Value/P&L/TWR), pagină per activ, import Trading 212/IBKR/XTB/CSV,
ordine cu dată în trecut și în moneda activului, raport anual (medie ponderată/FIFO), Telegram, backup, news.

### Ce trebuie știut despre fiecare
* **Monedă de raportare**: ordinele, alertele, watchlist-ul și raportul anual rămân în **RON** (moneda de stocare). Restul se
  recalculează în moneda aleasă; prima activare descarcă istoricul cursului.
* **Dividende**: sunt estimări din datele Yahoo (brut, la data ex-dividend). Verifică-le față de extrasul brokerului.
* **XIRR** se afișează doar cu minimum 3 luni de istoric (anualizarea unei perioade scurte induce în eroare).
* **Setup-ul** se atașează achiziției (loturile FIFO îl moștenesc). Statisticile numără *loturi închise*.
* **Sector/țară** vin de la Yahoo și pot lipsi; ETF-urile sunt împărțite pe ponderile sectoriale raportate, iar țara lor apare „Diversified”.

## Alerte care merg mereu
1. Pe ecranul de login bifează **„Keep me signed in on this computer”** (se salvează un token local, nu parola).
2. Setări → bifează **tray** și **pornire automată**.
3. (Opțional) Setări → Telegram: token de la **@BotFather** → trimite un mesaj botului → „Find my chat id” → Save.

Închiderea ferestrei o ascunde în tray; alertele continuă. „Quit” din meniul pictogramei oprește aplicația. „Sign out” uită
calculatorul. Pe Linux, tray-ul are nevoie de `pystray` + AppIndicator; dacă lipsește, funcția se dezactivează și Setările îți spun.

## Windows (fără Python instalat)
Trei variante:
* **GitHub (nu ai nevoie de Windows local)**: pune folderul într-un repository GitHub → Actions → „Build Windows app” → Run workflow.
  La final descarci `TraderNote-Setup.exe` și `TraderNote-windows.zip` din „Artifacts”.
* **Pe un PC Windows**: `build_windows.bat` (construiește executabilul și, dacă ai Inno Setup, installer-ul).
* **Manual**: `pip install -r requirements-dev.txt` apoi `python build_exe.py` → `dist/TraderNote/TraderNote.exe`.

Aplicația instalată își ține datele în `%APPDATA%\TraderNote` (dezinstalarea **nu** le șterge). Mod portabil: un fișier gol
`portable.txt` lângă `.exe` → datele se creează lângă el. Pornirea unei a doua instanțe doar o aduce în față pe prima.

## Teste
```
python -m pytest                        # 60 teste: logică, import, TWR, XIRR, risc, dividende, alerte, monedă, piață simulată, tray
xvfb-run -a python tests/gui_flows.py   # 63 verificări prin interfață (Linux; pe Windows/macOS rulează direct, fără xvfb)
xvfb-run -a python tests/gui_smoke.py /tmp/shots   # parcurge toate paginile și face capturi
```

## Structura
```
run.py                              punct de intrare (python run.py [--background])
tradernote/
  config util auth db                configurare, utilitare, parole + sesiune, SQLite + backup
  ledger performance reports         cost mediu, TWR/XIRR + benchmark, raport anual          (pure, testate)
  currency dividends alerts          monedă de raportare, propuneri de dividende, reguli     (pure, testate)
  risk journal_stats importer        risc și expunere, statistici de jurnal, import brokeri (pure, testate)
  market notify                      Yahoo (preț/istoric/dividende/profiluri/news), notificări
  tray autostart single_instance     system tray, pornire automată, o singură instanță
  ui/  app page_*.py dialogs charts widgets theme
tests/  build_exe.py  build_windows.bat  installer.iss  .github/workflows/build-windows.yml
```

## Limite
* **Neverificat din mediul de dezvoltare (Linux, fără internet)**: datele reale de la Yahoo și Telegram (testate doar cu răspunsuri
  simulate), notificările desktop pe Windows/macOS, tray-ul real pe Windows, pornirea automată pe Windows/macOS (cod scris după
  API-urile documentate), build-ul de `.exe` și installer-ul (workflow-ul și scripturile n-au rulat pe Windows). Binarul Linux
  construit cu aceleași opțiuni pornește corect, iar instanța unică a fost verificată pe el.
* Parserele de broker sunt scrise după formatele cunoscute și testate pe mostre sintetice; un export real nerecunoscut afișează coloanele găsite.
* Calculele în RON folosesc cursul zilei de la Yahoo, nu al unei bănci centrale. Raportul anual **nu este consultanță fiscală**.
* Token-ul Telegram și sesiunea locală sunt stocate necriptat pe calculatorul tău.
* Benchmark-ul este un indice de preț (fără dividende reinvestite).
