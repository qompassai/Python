[app]
title = OnTrack
package.name = ontrack
package.domain = org.qompassai
version = 1.0.0
android.manifest.application_name = OnTrack
source.dir = .
source.include_exts = py,kv,png,jpg,jpeg,ico,json
source.exclude_dirs = tests,__pycache__,.git,.github,venv,.venv,.mypy_cache
entrypoint = main.py
icon.filename = %(source.dir)s/assets/ontrack.png
presplash.filename = %(source.dir)s/assets/ontrack.jpg
fullscreen = 0
orientation = portrait
orientations = portrait,landscape
android.api = 35
android.minapi = 24
android.ndk = 26b
android.sdk = 35
android.ndk_api = 24
android.permissions = INTERNET,ACCESS_NETWORK_STATE,ACCESS_FINE_LOCATION,READ_EXTERNAL_STORAGE,WRITE_EXTERNAL_STORAGE
android.allow_backup = 0
android.hide_statusbar = 0
android.category = PRODUCTIVITY
android.archs = armeabi-v7a,arm64-v8a
android.features = android.hardware.location,android.hardware.location.gps
presplash.keep_on_top = 1
languages = en
requirements = python3,kivy,requests
# requirements = python3,kivy,kivymd,requests
# requirements = python3,kivy,requests,ortools
android.bootstrap = sdl2
kivy.app = main:OnTrackApp
kivy.kv_files = ontrack.kv,home.kv,results.kv,settings.kv
presplash.color = #FFFFFF
log_level = 2
android.copy_libs = 1
[buildozer]                                                
log_level = 2
build_workers = 0                                         
warn_on_root = 1
bin_dir = ./bin                                            
build_dir = ./.buildozer                                   
clean_build = 0                                            
[python-for-android]
extra_args = --pattern-whitelist="*.so" --enable-androidx
# blacklist =                                              
# whitelist =
