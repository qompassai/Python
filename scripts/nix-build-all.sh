#!/usr/bin/env bash
# nix-build-all.sh — Build all OnTrack packages and run checks via Nix
# Copyright (C) 2025 Qompass AI, All rights reserved
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DIST_DIR="$REPO_ROOT/dist/nix"

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

# ── Nix packages to build ──────────────────────────────────────────────────
PACKAGES=(
  "ontrack-rs-cli"
  "ontrack-rs-gui"
  "ontrack-py"
)

# ── Usage ───────────────────────────────────────────────────────────────────
usage() {
  cat <<EOF
${BOLD}OnTrack Nix Build Script${NC}

Usage: $(basename "$0") [OPTIONS]

Options:
  --build             Build all packages
  --check             Run all flake checks
  --all               Build + check (default)
  --package PKG       Build a specific package
  --collect           Copy build outputs to dist/nix/
  --system SYSTEM     Target system (default: auto-detect)
  -h, --help          Show this help

Packages:
$(printf '  - %s\n' "${PACKAGES[@]}")

Checks (run via nix flake check):
  - clippy            Rust lint with -D warnings
  - rust-test         Rust test suite
  - cargo-audit       CVE advisory check
  - cargo-deny        License and advisory check
  - pytest            Python test suite
  - bandit            Python security lint

Examples:
  $(basename "$0") --all
  $(basename "$0") --check
  $(basename "$0") --package ontrack-rs-cli --collect
EOF
}

# ── System detection ────────────────────────────────────────────────────────
detect_system() {
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

# ── Build functions ─────────────────────────────────────────────────────────
run_checks() {
  info "Running all flake checks..."
  cd "$REPO_ROOT"

  nix flake check --print-build-logs 2>&1 | while IFS= read -r line; do
    echo "  $line"
  done

  ok "All checks passed."
}

build_package() {
  local pkg="$1"
  info "Building .#$pkg ..."
  cd "$REPO_ROOT"

  nix build ".#$pkg" --print-build-logs 2>&1 | while IFS= read -r line; do
    echo "  $line"
  done

  ok "Built: $pkg"
}

build_all_packages() {
  for pkg in "${PACKAGES[@]}"; do
    build_package "$pkg"
    echo ""
  done
}

collect_outputs() {
  info "Collecting build outputs to $DIST_DIR/"
  mkdir -p "$DIST_DIR"
  cd "$REPO_ROOT"

  for pkg in "${PACKAGES[@]}"; do
    if [[ -L "result" ]] || nix build ".#$pkg" --no-link --print-build-logs &>/dev/null; then
      local store_path
      store_path=$(nix build ".#$pkg" --no-link --print-out-paths 2>/dev/null)
      if [[ -n "$store_path" ]]; then
        local pkg_dir="$DIST_DIR/$pkg"
        mkdir -p "$pkg_dir"
        cp -rL "$store_path"/* "$pkg_dir/" 2>/dev/null || true
        ok "Collected: $pkg -> $pkg_dir/"
      fi
    else
      warn "Could not collect: $pkg"
    fi
  done
}

# ── Main ────────────────────────────────────────────────────────────────────
main() {
  local do_build=false
  local do_check=false
  local do_collect=false
  local single_pkg=""
  local do_all=false

  if [[ $# -eq 0 ]]; then
    do_all=true
  fi

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --build)
        do_build=true
        shift
        ;;
      --check)
        do_check=true
        shift
        ;;
      --all)
        do_all=true
        shift
        ;;
      --package)
        single_pkg="${2:?'--package requires an argument'}"
        shift 2
        ;;
      --collect)
        do_collect=true
        shift
        ;;
      --system)
        shift 2 # accepted but we use auto-detect
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

  local system
  system="$(detect_system)"
  info "Target system: $system"

  if $do_all; then
    do_build=true
    do_check=true
  fi

  if [[ -n "$single_pkg" ]]; then
    build_package "$single_pkg"
  fi

  if $do_build && [[ -z "$single_pkg" ]]; then
    build_all_packages
  fi

  if $do_check; then
    run_checks
  fi

  if $do_collect; then
    collect_outputs
  fi

  echo ""
  ok "Nix build pipeline complete."
}

main "$@"
