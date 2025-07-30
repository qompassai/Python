#!/bin/sh
# /qompassai/python/scripts/quickstart.sh
# Qompass AI Python Quick Start + pyenv/ruff/uv + config
# Copyright (C) 2025 Qompass AI, All rights reserved
#########################################################
set -eu
IFS='
'
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
LOCAL_PREFIX="$HOME/.local"
BIN_DIR="$LOCAL_PREFIX/bin"
LIB_DIR="$LOCAL_PREFIX/lib"
SHARE_DIR="$LOCAL_PREFIX/share"
SRC_DIR="$HOME/.local/src/python"
PYENV_ROOT="$HOME/.pyenv"
mkdir -p "$BIN_DIR" "$LIB_DIR" "$SHARE_DIR" "$SRC_DIR" "$XDG_CONFIG_HOME/python"
case ":$PATH:" in
*":$BIN_DIR:"*) ;;
*) export PATH="$BIN_DIR:$PATH" ;;
esac
NEEDED_TOOLS="git curl tar make gcc clang"
PY_VERS="3.13.5"
PY_MAJ="3.13"
printf '╭────────────────────────────────────────────╮\n'
printf '│      Qompass AI · Python Quick‑Start       │\n'
printf '╰────────────────────────────────────────────╯\n'
printf '   © 2025 Qompass AI. All rights reserved   \n\n'
echo "Which Python do you want to build?"
echo " 1) Classic CPython (${PY_VERS})"
echo " 2) Free-threaded (GIL-free, experimental, --enable-free-threaded-interpreter)"
echo " q) Quit"
printf "Choose [1]: "
read -r ans
[ -z "$ans" ] && ans=1
[ "$ans" = "q" ] && exit 0
FREE_THREADED="no"
if [ "$ans" = "2" ]; then
        FREE_THREADED="yes"
fi
cd "$SRC_DIR"
if [ ! -d "cpython" ]; then
        echo "→ Cloning Python source (cpython)..."
        git clone --branch "v$PY_VERS" https://github.com/python/cpython.git
fi
cd cpython
git fetch origin
git checkout "v$PY_VERS"
git clean -fdx
echo "→ Configuring Python build..."
CONFIG_FLAGS="--prefix=$LOCAL_PREFIX"
if [ "$FREE_THREADED" = "yes" ]; then
        CONFIG_FLAGS="$CONFIG_FLAGS --enable-free-threaded-interpreter"
fi
./configure "$CONFIG_FLAGS"
echo "→ Building Python (this may take several minutes, enabling PGO/LTO optimization)..."
export CFLAGS="-Wno-error=date-time"
make -j"$(nproc)"
echo "→ Installing Python (no sudo needed)..."
make install
case ":$PATH:" in
*":$BIN_DIR:"*) ;;
*) export PATH="$BIN_DIR:$PATH" ;;
esac
add_path_to_shell_rc() {
        rcfile=$1
        line="export PATH=\"$BIN_DIR:\$PATH\""
        if [ -f "$rcfile" ]; then
                if ! grep -Fxq "$line" "$rcfile"; then
                        printf '\n# Added by Qompass AI Python quickstart script\n%s\n' "$line" >>"$rcfile"
                        echo " → Added PATH export to $rcfile"
                fi
        fi
}
add_path_to_shell_rc "$HOME/.bashrc"
add_path_to_shell_rc "$HOME/.zshrc"
add_path_to_shell_rc "$HOME/.profile"
PIP_PATH="$BIN_DIR/pip$PY_MAJ"
PYTHON_PATH="$BIN_DIR/python$PY_MAJ"
echo "→ Upgrading pip and installing core wheels..."
"$PYTHON_PATH" -m ensurepip --upgrade
"$PYTHON_PATH" -m pip install --upgrade pip wheel setuptools
echo
printf "Do you want to install \033[1mpyenv\033[0m for managing multiple Pythons? [Y/n]: "
read -r ans
[ -z "$ans" ] && ans="Y"
if [ "$ans" = "Y" ] || [ "$ans" = "y" ]; then
        if [ ! -d "$PYENV_ROOT" ]; then
                curl -fsSL https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
                # Add pyenv to shell
                for rc in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
                        if [ -f "$rc" ]; then
                                if ! grep -q "pyenv init" "$rc"; then
                                        printf '\n# Pyenv config\nexport PYENV_ROOT="%s"\nexport PATH="$PYENV_ROOT/bin:$PATH"\neval "$(pyenv init --path)"\n' "$PYENV_ROOT" >>"$rc"
                                        echo " → Added pyenv setup to $rc"
                                fi
                        fi
                done
        else
                echo "→ pyenv already present."
        fi
fi
echo
printf "Do you want to install \033[1mruff\033[0m (fast Python linter)? [Y/n]: "
read -r ans
[ -z "$ans" ] && ans="Y"
if [ "$ans" = "Y" ] || [ "$ans" = "y" ]; then
        "$PIP_PATH" install --user ruff
        echo "→ ruff installed via pip"
fi
echo
printf "Do you want to install \033[1muv\033[0m (pip replacement and package manager)? [Y/n]: "
read -r ans
[ -z "$ans" ] && ans="Y"
if [ "$ans" = "Y" ] || [ "$ans" = "y" ]; then
        if command -v pipx >/dev/null 2>&1; then
                pipx install uv || "$PIP_PATH" install --user uv
        else
                "$PIP_PATH" install --user uv
        fi
        echo "→ uv installed"
fi
create_xdg_config() {
        tool="$1"
        default_content="$2"
        confdir="$XDG_CONFIG_HOME/$tool"
        confpath="$confdir/config.toml"
        mkdir -p "$confdir"
        if [ -f "$confpath" ]; then
                echo "→ $tool config already exists at $confpath"
                return
        fi
        printf "Do you want to write an example config for $tool to %s? [Y/n]: " "$confpath"
        read -r ans
        [ -z "$ans" ] && ans="Y"
        if [ "$ans" = "Y" ] || [ "$ans" = "y" ]; then
                echo "→ Creating example $tool config at $confpath"
                printf "%s\n" "$default_content" >"$confpath"
        fi
}
RUFF_CFG='[lint]\nselect = ["E", "F", "W"] # Example: style, errors, warnings'
UV_CFG='[uv]\npypi_mirror = "https://pypi.org/simple"\ncache_dir = "~/.cache/uv"\n'
PYTHON_CFG='[startup]\n# Put any sitecustomize or startup hooks here\n'
create_xdg_config "ruff" "$RUFF_CFG"
create_xdg_config "uv" "$UV_CFG"
create_xdg_config "python" "$PYTHON_CFG"
echo
echo "✅ Python $PY_VERS has been built and installed in $BIN_DIR"
if [ "$FREE_THREADED" = "yes" ]; then
        echo " (Free-threaded interpreter enabled!)"
fi
echo "→ Test it with: $PYTHON_PATH --version"
echo "→ Your pip is: $PIP_PATH"
echo "→ pyenv (if installed) is in \$HOME/.pyenv; add to your PATH if desired."
echo "→ ruff and uv are installed in ~/.local/bin (and can be configured in $XDG_CONFIG_HOME/)"
echo "→ All binaries/libs/configs are under ~/.local/, ~/.pyenv/, ~/.config/"
echo "→ Add '$BIN_DIR' to your shell \$PATH if not already present."
echo "→ For custom packages, use: $PIP_PATH install --user ..."
echo "→ To uninstall, just rm -rf $LOCAL_PREFIX/{bin/lib/share} $SRC_DIR/cpython ~/.pyenv ~/.cache/ruff ~/.cache/uv $XDG_CONFIG_HOME/ruff $XDG_CONFIG_HOME/uv"
echo "─ Ready, Set, Python! ─"
exit 0
