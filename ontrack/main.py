#!/usr/bin/env python3
"""
main.py — OnTrack entry point.

Detects runtime environment and launches the appropriate UI:
  - Desktop (Windows/Linux): CustomTkinter GUI
  - Android: Kivy GUI
"""

import sys
import os

# Detect platform
try:
    import android  # type: ignore
    _PLATFORM = "android"
except ImportError:
    _PLATFORM = "desktop"


def _run_desktop():
    from gui.app import ONTrackApp
    app = ONTrackApp()
    app.mainloop()


def _run_mobile():
    from mobile.app import OnTrackMobileApp
    OnTrackMobileApp().run()


if __name__ == "__main__":
    if _PLATFORM == "android" or "--mobile" in sys.argv:
        _run_mobile()
    else:
        _run_desktop()
