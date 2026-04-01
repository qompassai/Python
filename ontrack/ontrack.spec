# -*- mode: python ; coding: utf-8 -*-
# OnTrack v2 — PyInstaller spec for Windows and Linux x86_64.
# Build: pyinstaller ontrack.spec

import sys
import os

block_cipher = None

a = Analysis(
    ["main.py"],
    pathex=["."],
    binaries=[],
    datas=[
        ("assets",  "assets"),
        ("config",  "config"),
    ],
    hiddenimports=[
        # OR-Tools internal modules
        "ortools",
        "ortools.constraint_solver",
        "ortools.constraint_solver.pywrapcp",
        "ortools.constraint_solver.routing_enums_pb2",
        # geopy backends
        "geopy.geocoders",
        "geopy.geocoders.nominatim",
        # pandas engines
        "openpyxl",
        "pandas",
        # CustomTkinter
        "customtkinter",
        "PIL",
        "PIL.Image",
        "PIL.ImageTk",
        # dotenv
        "dotenv",
        # requests
        "requests",
        "certifi",
        "charset_normalizer",
        "urllib3",
    ],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=["kivy", "android", "jnius", "plyer"],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)

pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.zipfiles,
    a.datas,
    [],
    name="OnTrack",
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=False,   # no console window on Windows
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    icon=os.path.join("assets", "ontrack.ico") if sys.platform == "win32" else None,
)
