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
</p>

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
