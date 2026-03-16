<p align="center">
  <img src="assets/ontrack.jpg" alt="ONTrack" width="150"/>
</p>

<h1 align="center">ONTrack</h1>

<p align="center">
  <b>Route Optimizer for Folks in a Hurry</b><br/>
  Built with Python · OR-Tools · CustomTkinter
</p>

<p align="center">
  <img src="https://img.shields.io/badge/python-3.11+-blue?style=flat-square"/>
  <img src="https://img.shields.io/badge/platform-Windows-informational?style=flat-square"/>
  <img src="https://img.shields.io/badge/license-MIT-green?style=flat-square"/>
  <img src="https://img.shields.io/badge/status-active-brightgreen?style=flat-square"/>
  <img src="https://img.shields.io/badge/OR--Tools-routing-orange?style=flat-square"/>
  <img src="https://img.shields.io/badge/🚧%20WIP-not%20production%20ready-yellow?style=flat-square"/>
</p>

> [!WARNING]
> ONTrack is a **work in progress**. Core routing logic is functional but the GUI, installer, and map preview are still being built out. Not recommended for production field use yet.

---

## What It Does

ONTrack takes a CSV or Excel file of street addresses, geocodes them, builds a real-road distance matrix, and solves the optimal drive order using Google OR-Tools — then exports the route and opens it directly in Google Maps.

---

## Quick Start

```bash
git clone https://github.com/Qompass/ontrack.git
cd ontrack
pip install -r requirements.txt
python main.py
```

***
<details> <summary>📁 Project Structure</summary>

```python
ontrack/
├── main.py
├── ontrack.spec
├── app_icon.ico
├── README.md
├── requirements.txt
│
├── gui/
│   ├── __init__.py
│   ├── app.py
│   ├── views/
│   │   ├── __init__.py
│   │   ├── home.py
│   │   ├── results.py
│   │   └── settings.py
│   └── components/
│       ├── __init__.py
│       ├── file_picker.py
│       ├── address_table.py
│       └── map_preview.py
│
├── core/
│   ├── __init__.py
│   ├── parser.py
│   ├── geocoder.py
│   ├── matrix.py
│   ├── solver.py
│   └── exporter.py
│
├── assets/
│   ├── icon.png
│   ├── icon.ico
│   └── themes/
│       └── ontrack.json
│
├── config/
│   ├── __init__.py
│   └── settings.py
│
├── tests/
│   ├── test_parser.py
│   ├── test_geocoder.py
│   ├── test_solver.py
│   └── sample_addresses.csv
│
└── build/
    └── (PyInstaller output, gitignored)
```
</details>

<details> <summary>⚙️ How It Works</summary>
| Step | Module           | Description                                              |
| ---- | ---------------- | -------------------------------------------------------- |
| 1    | core/parser.py   | Reads CSV or Excel, extracts address column              |
| 2    | core/geocoder.py | Geocodes each address to lat/lng via Nominatim or Google |
| 3    | core/matrix.py   | Builds NxN real-road distance matrix via OSRM            |
| 4    | core/solver.py   | Solves TSP with OR-Tools, returns ordered stop list      |
| 5    | core/exporter.py | Exports sorted CSV + opens Google Maps deep link         |
 </details>

Here's the fully upgraded README with a WIP notice, more visual flair, and additional sections:

text
# ONTrack

<p align="center">
  <img src="assets/ontrack.jpg" alt="ONTrack" width="150"/>
</p>

<h1 align="center">ONTrack</h1>

<p align="center">
  <b>Route Optimizer for Folks in a Hurry</b><br/>
  Built with Python · OR-Tools · CustomTkinter
</p>

<p align="center">
  <img src="https://img.shields.io/badge/python-3.11+-blue?style=flat-square"/>
  <img src="https://img.shields.io/badge/platform-Windows-informational?style=flat-square"/>
  <img src="https://img.shields.io/badge/license-MIT-green?style=flat-square"/>
  <img src="https://img.shields.io/badge/status-active-brightgreen?style=flat-square"/>
  <img src="https://img.shields.io/badge/OR--Tools-routing-orange?style=flat-square"/>
  <img src="https://img.shields.io/badge/🚧%20WIP-not%20production%20ready-yellow?style=flat-square"/>
</p>

> [!WARNING]
> ONTrack is a **work in progress**. Core routing logic is functional but the GUI, installer, and map preview are still being built out. Not recommended for production field use yet.

---

## What It Does

ONTrack takes a CSV or Excel file of street addresses, geocodes them, builds a real-road distance matrix, and solves the optimal drive order using Google OR-Tools — then exports the route and opens it directly in Google Maps.

---

## Quick Start

> [!NOTE]
> Requires Python 3.11+ and pip. Windows `.exe` build coming soon.

```bash
git clone https://github.com/qompassai/python.git
cd python/ontrack
pip install -r requirements.txt
python main.py

Roadmap

    Project scaffold and structure

    CSV/Excel parser (core/parser.py)

    Geocoder with Nominatim (core/geocoder.py)

    OSRM distance matrix builder

    OR-Tools TSP solver

    CustomTkinter GUI

    Google Maps deep link export

    PyInstaller .exe build

    Desktop shortcut + icon installer

<details> <summary>📁 Project Structure</summary>

text
ontrack/
├── main.py                  # Entrypoint
├── ontrack.spec             # PyInstaller build spec
├── README.md
├── requirements.txt
│
├── gui/
│   ├── app.py               # CTk root window
│   ├── views/
│   │   ├── home.py          # File picker + depot input
│   │   ├── results.py       # Route display table
│   │   └── settings.py      # API keys + prefs
│   └── components/
│       ├── file_picker.py
│       ├── address_table.py
│       └── map_preview.py
│
├── core/
│   ├── parser.py            # CSV/Excel → address list
│   ├── geocoder.py          # Address → lat/lng
│   ├── matrix.py            # Distance matrix (OSRM)
│   ├── solver.py            # OR-Tools TSP
│   └── exporter.py          # CSV + Maps URL
│
├── assets/
│   ├── ontrack.jpg
│   ├── ontrack.png
│   ├── ontrack.ico
│   └── themes/ontrack.json
│
├── config/
│   └── settings.py          # dotenv API key loader
│
└── tests/
    ├── test_parser.py
    ├── test_geocoder.py
    ├── test_solver.py
    └── sample_addresses.csv

</details>
```

<details> <summary>⚙️ How It Works</summary>
Step	Module	Description
1	core/parser.py	Reads CSV or Excel, extracts address column
2	core/geocoder.py	Geocodes each address to lat/lng via Nominatim or Google
3	core/matrix.py	Builds NxN real-road distance matrix via OSRM
4	core/solver.py	Solves TSP with OR-Tools, returns ordered stop list
5	core/exporter.py	Exports sorted CSV + opens Google Maps deep link
</details>

<details>
<summary>🔑 Configuration</summary>

ONTrack works **fully out of the box with no API keys**. All default services are free and open:

| Service | Provider | Key Required |
|---------|----------|-------------|
| Geocoding | Nominatim (OpenStreetMap) | ❌ None |
| Routing | OSRM public server | ❌ None |
| Map preview | Folium + OpenStreetMap | ❌ None |
| Route export | Google Maps URL | ❌ None |

Optionally drop a `.env` file in the project root to upgrade to Google Maps for better rural accuracy:

```bash
cp .env.example .env
<details>
<summary>🪟 Building the Windows .exe</summary>
```

```bash
pyinstaller --onefile --windowed \
  --icon=assets/ontrack.ico \
  --name="ONTrack" \
  --add-data "assets;assets" \
  --hidden-import ortools \
  main.py
```

Output: dist/ONTrack.exe — no Python install required on target machine.
</details>
