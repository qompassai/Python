# -*- mode: python ; coding: utf-8 -*-
# PyInstaller spec for the OnTrack Python INSTALLER binary.
# The installer bundles the entire ontrack/ source tree so it is self-contained.
#
# Build:
#   cd ontrack/installer
#   pyinstaller installer.spec
#
# Output:
#   dist/OnTrackInstaller.exe   (Windows)
#   dist/OnTrackInstaller       (Linux)

import sys
import os
import pathlib

# Root of the ontrack project (one level up from installer/)
APP_ROOT = str(pathlib.Path(SPECPATH).parent)

block_cipher = None

a = Analysis(
    [os.path.join(SPECPATH, "ontrack_installer.py")],
    pathex=[SPECPATH, APP_ROOT],
    binaries=[],
    datas=[
        # Bundle the entire ontrack app source tree
        (os.path.join(APP_ROOT, "main.py"),           "."),
        (os.path.join(APP_ROOT, "requirements.txt"),  "."),
        (os.path.join(APP_ROOT, "requirements-android.txt"), "."),
        (os.path.join(APP_ROOT, "assets"),            "assets"),
        (os.path.join(APP_ROOT, "config"),            "config"),
        (os.path.join(APP_ROOT, "core"),              "core"),
        (os.path.join(APP_ROOT, "gui"),               "gui"),
        (os.path.join(APP_ROOT, "mobile"),            "mobile"),
        (os.path.join(APP_ROOT, ".env.example"),      "."),
    ],
    hiddenimports=[
        "customtkinter",
        "PIL",
        "PIL.Image",
        "PIL.ImageTk",
    ],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=["ortools", "kivy", "android", "jnius"],
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
    name="OnTrackInstaller",
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=False,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    icon=os.path.join(APP_ROOT, "assets", "ontrack.ico") if sys.platform == "win32" else None,
    version_file=None,
)
