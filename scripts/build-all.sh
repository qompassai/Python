#!/usr/bin/env bash
# build-all.sh — Master build script for OnTrack (Python + Rust)
# Copyright (C) 2025 Qompass AI, All rights reserved
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DIST_DIR="$REPO_ROOT/dist"

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

# ── Platform detection ──────────────────────────────────────────────────────
detect_platform() {
  local os arch
  os="$(uname -s | tr '[:upper:]' '[:lower:]')"
  arch="$(uname -m)"

  case "$os" in
    linux)  os="linux" ;;
    darwin) os="darwin" ;;
    *)      err "Unsupported OS: $os"; exit 1 ;;
  esac

  case "$arch" in
    x86_64|amd64)   arch="x86_64" ;;
    aarch64|arm64)   arch="aarch64" ;;
    *)               err "Unsupported arch: $arch"; exit 1 ;;
  esac

  echo "${arch}-${os}"
}

# ── Available targets ───────────────────────────────────────────────────────
RUST_TARGETS=(
  "x86_64-unknown-linux-gnu"
  "aarch64-unknown-linux-gnu"
  "x86_64-apple-darwin"
  "aarch64-apple-darwin"
  "x86_64-pc-windows-gnu"
)

PYTHON_TARGETS=(
  "host"
  "android"
)

list_targets() {
  echo -e "${BOLD}Available Rust cross-compilation targets:${NC}"
  for t in "${RUST_TARGETS[@]}"; do
    echo "  - $t"
  done
  echo ""
  echo -e "${BOLD}Available Python build targets:${NC}"
  for t in "${PYTHON_TARGETS[@]}"; do
    echo "  - $t"
  done
}

# ── Build functions ─────────────────────────────────────────────────────────
build_rust() {
  local target="${1:-}"
  info "Building Rust workspace..."

  cd "$REPO_ROOT/ontrack-rs"

  if [[ -n "$target" ]]; then
    info "Cross-compiling for target: $target"
    "$SCRIPT_DIR/cross-compile-rs.sh" --target "$target"
  else
    info "Building for host platform (release)..."
    cargo build --release

    local host_dir="$DIST_DIR/rust/host"
    mkdir -p "$host_dir"

    if [[ -f target/release/ontrack ]]; then
      cp target/release/ontrack "$host_dir/"
      ok "CLI binary: $host_dir/ontrack"
    fi
    if [[ -f target/release/ontrack-gui ]]; then
      cp target/release/ontrack-gui "$host_dir/"
      ok "GUI binary: $host_dir/ontrack-gui"
    fi
  fi

  cd "$REPO_ROOT"
}

build_python() {
  local target="${1:-host}"
  info "Building Python package..."
  "$SCRIPT_DIR/build-python.sh" --target "$target"
}

# ── Usage ───────────────────────────────────────────────────────────────────
usage() {
  cat <<EOF
${BOLD}OnTrack Master Build Script${NC}

Usage: $(basename "$0") [OPTIONS]

Options:
  --all                Build everything for the host platform
  --rust               Build Rust workspace only
  --python             Build Python package only
  --target TARGET      Cross-compile Rust for the specified target triple
  --list-targets       List available compilation targets
  --dist-dir DIR       Override output directory (default: dist/)
  -h, --help           Show this help

Examples:
  $(basename "$0") --all
  $(basename "$0") --rust --target aarch64-unknown-linux-gnu
  $(basename "$0") --python --target android
  $(basename "$0") --list-targets
EOF
}

# ── Main ────────────────────────────────────────────────────────────────────
main() {
  local do_rust=false
  local do_python=false
  local target=""

  if [[ $# -eq 0 ]]; then
    usage
    exit 0
  fi

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --all)
        do_rust=true
        do_python=true
        shift
        ;;
      --rust)
        do_rust=true
        shift
        ;;
      --python)
        do_python=true
        shift
        ;;
      --target)
        target="${2:?'--target requires an argument'}"
        shift 2
        ;;
      --list-targets)
        list_targets
        exit 0
        ;;
      --dist-dir)
        DIST_DIR="${2:?'--dist-dir requires an argument'}"
        shift 2
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

  local platform
  platform="$(detect_platform)"
  info "Host platform: $platform"
  info "Output directory: $DIST_DIR"
  mkdir -p "$DIST_DIR"

  if $do_rust; then
    build_rust "$target"
  fi

  if $do_python; then
    build_python "$target"
  fi

  echo ""
  ok "Build complete. Outputs in $DIST_DIR/"
}

main "$@"
