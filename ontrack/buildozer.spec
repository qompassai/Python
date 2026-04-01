[app]
# ── Identity ─────────────────────────────────────────────────────────────────
title = OnTrack
package.name = ontrack
package.domain = com.tds.ontrack
version = 2.0.0
android.manifest.application_name = OnTrack

# ── Source ───────────────────────────────────────────────────────────────────
source.dir = .
source.include_exts = py,kv,png,jpg,jpeg,ico,json,csv
source.include_patterns = assets/*,mobile/*,core/*,config/*
source.exclude_dirs = tests,__pycache__,.git,.github,venv,.venv,.mypy_cache,gui,dist,build,.buildozer,bin

# Entry point: main.py will detect Android and launch Kivy UI
entrypoint = main.py

# ── Assets ───────────────────────────────────────────────────────────────────
icon.filename            = %(source.dir)s/assets/ontrack.png
presplash.filename       = %(source.dir)s/assets/ontrack.jpg
presplash.color          = #002855
presplash.keep_on_top    = 1

# ── Display ──────────────────────────────────────────────────────────────────
fullscreen     = 0
orientation    = portrait
orientations   = portrait,landscape

# ── Android SDK / NDK ────────────────────────────────────────────────────────
android.api     = 35
android.minapi  = 26
android.ndk     = 26b
android.sdk     = 35
android.ndk_api = 26

# ── Permissions ──────────────────────────────────────────────────────────────
android.permissions = \
    INTERNET,\
    ACCESS_NETWORK_STATE,\
    ACCESS_FINE_LOCATION,\
    ACCESS_COARSE_LOCATION,\
    ACCESS_BACKGROUND_LOCATION,\
    READ_EXTERNAL_STORAGE,\
    WRITE_EXTERNAL_STORAGE

# ── Hardware features ────────────────────────────────────────────────────────
android.features = android.hardware.location,android.hardware.location.gps

# ── Build config ─────────────────────────────────────────────────────────────
android.archs           = armeabi-v7a,arm64-v8a
android.bootstrap       = sdl2
android.allow_backup    = 0
android.hide_statusbar  = 0
android.category        = PRODUCTIVITY
android.copy_libs       = 1
android.manifest.intent_filters =

# ── Python-for-android requirements ──────────────────────────────────────────
# NOTE: ortools is intentionally excluded — no p4a recipe exists.
# The solver.py automatically falls back to nearest-neighbor on Android.
requirements = \
    python3,\
    kivy==2.2.1,\
    requests,\
    geopy,\
    python-dotenv,\
    Pillow,\
    plyer

# ── KV files ─────────────────────────────────────────────────────────────────
# (inline KV in Python files; no separate .kv needed)

# ── Languages ────────────────────────────────────────────────────────────────
languages = en

[buildozer]
log_level     = 2
build_workers = 0
warn_on_root  = 1
bin_dir       = ./bin
build_dir     = ./.buildozer
clean_build   = 0

[python-for-android]
extra_args = --pattern-whitelist="*.so" --enable-androidx
