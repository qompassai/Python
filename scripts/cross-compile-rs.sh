#!/usr/bin/env bash
# cross-compile-rs.sh — Cross-compile OnTrack Rust binaries
# Uses `cross` (cross-rs) when available, falls back to cargo with target
# Copyright (C) 2025 Qompass AI, All rights reserved
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
RUST_DIR="$REPO_ROOT/ontrack-rs"
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

# ── Supported targets ──────────────────────────────────────────────────────
TARGETS=(
  "x86_64-unknown-linux-gnu"
  "aarch64-unknown-linux-gnu"
  "x86_64-apple-darwin"
  "aarch64-apple-darwin"
  "x86_64-pc-windows-gnu"
)

# ── Usage ───────────────────────────────────────────────────────────────────
usage() {
  cat <<EOF
${BOLD}OnTrack Rust Cross-Compilation Script${NC}

Usage: $(basename "$0") [OPTIONS]

Options:
  --target TARGET    Build for a specific target triple
  --all              Build for all supported targets
  --cli-only         Build only the CLI binary (skip GUI)
  --gui-only         Build only the GUI binary (skip CLI)
  --list             List available targets
  --dist-dir DIR     Override output directory (default: dist/)
  -h, --help         Show this help

Supported targets:
$(printf '  - %s\n' "${TARGETS[@]}")

Examples:
  $(basename "$0") --target x86_64-unknown-linux-gnu
  $(basename "$0") --all --cli-only
  $(basename "$0") --target aarch64-apple-darwin
EOF
}

# ── Build helpers ───────────────────────────────────────────────────────────
has_cross() {
  command -v cross &>/dev/null
}

build_target() {
  local target="$1"
  local build_cli="${2:-true}"
  local build_gui="${3:-true}"

  info "Building for target: $target"

  local builder="cargo"
  if has_cross; then
    builder="cross"
    info "Using cross-rs for cross-compilation"
  else
    warn "cross-rs not found, using cargo (may fail for non-host targets)"
    warn "Install: cargo install cross --git https://github.com/cross-rs/cross"
  fi

  local out_dir="$DIST_DIR/$target"
  mkdir -p "$out_dir"

  cd "$RUST_DIR"

  # Determine binary extension
  local ext=""
  if [[ "$target" == *windows* ]]; then
    ext=".exe"
  fi

  # Build CLI
  if [[ "$build_cli" == "true" ]]; then
    info "  Building ontrack-cli..."
    $builder build --release --target "$target" -p ontrack-cli

    local cli_src="target/$target/release/ontrack${ext}"
    if [[ -f "$cli_src" ]]; then
      cp "$cli_src" "$out_dir/ontrack${ext}"
      ok "  CLI: $out_dir/ontrack${ext}"
    else
      warn "  CLI binary not found at $cli_src"
    fi
  fi

  # Build GUI (skip for Windows cross-compile — GUI deps are complex)
  if [[ "$build_gui" == "true" ]]; then
    if [[ "$target" == *windows* ]]; then
      warn "  Skipping GUI for Windows target (egui cross-compile needs manual setup)"
    else
      info "  Building ontrack-gui..."
      $builder build --release --target "$target" -p ontrack-gui || {
        warn "  GUI build failed for $target (may need system deps)"
      }

      local gui_src="target/$target/release/ontrack-gui${ext}"
      if [[ -f "$gui_src" ]]; then
        cp "$gui_src" "$out_dir/ontrack-gui${ext}"
        ok "  GUI: $out_dir/ontrack-gui${ext}"
      fi
    fi
  fi

  cd "$REPO_ROOT"
}

# ── Main ────────────────────────────────────────────────────────────────────
main() {
  local target=""
  local build_all=false
  local cli_only=false
  local gui_only=false

  if [[ $# -eq 0 ]]; then
    usage
    exit 0
  fi

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --target)
        target="${2:?'--target requires an argument'}"
        shift 2
        ;;
      --all)
        build_all=true
        shift
        ;;
      --cli-only)
        cli_only=true
        shift
        ;;
      --gui-only)
        gui_only=true
        shift
        ;;
      --list)
        echo -e "${BOLD}Supported targets:${NC}"
        printf '  %s\n' "${TARGETS[@]}"
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

  local do_cli="true"
  local do_gui="true"
  if $cli_only; then do_gui="false"; fi
  if $gui_only; then do_cli="false"; fi

  mkdir -p "$DIST_DIR"

  if $build_all; then
    info "Building for all targets..."
    for t in "${TARGETS[@]}"; do
      build_target "$t" "$do_cli" "$do_gui"
      echo ""
    done
  elif [[ -n "$target" ]]; then
    build_target "$target" "$do_cli" "$do_gui"
  else
    err "Specify --target TARGET or --all"
    exit 1
  fi

  echo ""
  ok "Cross-compilation complete."
  info "Binaries in: $DIST_DIR/"
  ls -la "$DIST_DIR"/*/ontrack* 2>/dev/null || true
}

main "$@"
