#!/usr/bin/env bash
# build-python.sh — Build OnTrack Python package (wheel, standalone, Android)
# Copyright (C) 2025 Qompass AI, All rights reserved
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PYTHON_DIR="$REPO_ROOT/ontrack"
DIST_DIR="$REPO_ROOT/dist/python"

# ── Colors ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

info()  { echo -e "${CYAN}[INFO]${NC} $*"; }
ok()    { echo -e "${GREEN}[OK]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
err()   { echo -e "${RED}[ERR]${NC} $*" >&2; }

# ── Usage ───────────────────────────────────────────────────────────────────
usage() {
  cat <<EOF
${BOLD}OnTrack Python Build Script${NC}

Usage: $(basename "$0") [OPTIONS]

Options:
  --target TARGET    Build target: host (default), wheel, standalone, android
  --dist-dir DIR     Override output directory (default: dist/python/)
  --all              Build all targets (wheel + standalone)
  -h, --help         Show this help

Targets:
  host        Build maturin wheel for the current platform
  wheel       Build maturin wheel (alias for host)
  standalone  Build PyInstaller standalone binary
  android     Build Android APK via buildozer
  all         Build wheel + standalone

Examples:
  $(basename "$0")                        # Build wheel for host
  $(basename "$0") --target standalone    # Build PyInstaller binary
  $(basename "$0") --target android       # Build Android APK
  $(basename "$0") --all                  # Build wheel + standalone
EOF
}

# ── Build wheel via maturin ─────────────────────────────────────────────────
build_wheel() {
  info "Building Python wheel via maturin..."
  cd "$PYTHON_DIR"

  if command -v maturin &>/dev/null; then
    maturin build --release --out "$DIST_DIR/wheel/"
    ok "Wheel built in $DIST_DIR/wheel/"
  else
    warn "maturin not found, falling back to pip wheel..."
    pip wheel . --wheel-dir "$DIST_DIR/wheel/" --no-deps
    ok "Wheel built in $DIST_DIR/wheel/"
  fi

  cd "$REPO_ROOT"
}

# ── Build standalone via PyInstaller ────────────────────────────────────────
build_standalone() {
  info "Building standalone binary via PyInstaller..."
  cd "$PYTHON_DIR"

  if ! command -v pyinstaller &>/dev/null; then
    err "PyInstaller not found. Install with: pip install pyinstaller"
    exit 1
  fi

  local spec_file="ontrack.spec"
  if [[ -f "$spec_file" ]]; then
    info "Using existing .spec file: $spec_file"
    pyinstaller "$spec_file" --distpath "$DIST_DIR/standalone/" --workpath "/tmp/ontrack-build" --noconfirm
  else
    info "Building with auto-detection..."
    pyinstaller main.py \
      --name ontrack \
      --onefile \
      --noconsole \
      --distpath "$DIST_DIR/standalone/" \
      --workpath "/tmp/ontrack-build" \
      --noconfirm \
      --add-data "assets:assets" \
      --hidden-import customtkinter \
      --hidden-import PIL
  fi

  ok "Standalone binary: $DIST_DIR/standalone/"
  cd "$REPO_ROOT"
}

# ── Build Android APK via buildozer ─────────────────────────────────────────
build_android() {
  info "Building Android APK via buildozer..."
  cd "$PYTHON_DIR"

  if ! command -v buildozer &>/dev/null; then
    err "buildozer not found. Install with: pip install buildozer"
    exit 1
  fi

  if [[ ! -f "buildozer.spec" ]]; then
    err "buildozer.spec not found in $PYTHON_DIR"
    exit 1
  fi

  info "This may take a while on first run (downloads Android SDK/NDK)..."
  buildozer android debug 2>&1 | tail -20

  # Copy APK to dist
  mkdir -p "$DIST_DIR/android/"
  local apk
  apk=$(find bin/ -name "*.apk" -type f 2>/dev/null | head -1)
  if [[ -n "$apk" ]]; then
    cp "$apk" "$DIST_DIR/android/"
    ok "APK: $DIST_DIR/android/$(basename "$apk")"
  else
    warn "APK not found in bin/ — check buildozer output"
  fi

  cd "$REPO_ROOT"
}

# ── Main ────────────────────────────────────────────────────────────────────
main() {
  local target="host"
  local build_all=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --target)
        target="${2:?'--target requires an argument'}"
        shift 2
        ;;
      --dist-dir)
        DIST_DIR="${2:?'--dist-dir requires an argument'}"
        shift 2
        ;;
      --all)
        build_all=true
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        err "Unknown option: $1"
        usage
        exit 1
        ;;
    esac
  done

  mkdir -p "$DIST_DIR"

  if $build_all; then
    build_wheel
    build_standalone
    echo ""
    ok "All Python builds complete."
    return
  fi

  case "$target" in
    host|wheel)
      build_wheel
      ;;
    standalone)
      build_standalone
      ;;
    android)
      build_android
      ;;
    *)
      err "Unknown target: $target"
      err "Valid targets: host, wheel, standalone, android"
      exit 1
      ;;
  esac
}

main "$@"
