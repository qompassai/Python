#!/bin/sh
# /qompassai/python/scripts/quickstart.sh
# Qompass AI Python Quick Start
# Copyright (C) 2025 Qompass AI, All rights reserved
#########################################################
set -eu
PREFIX="$HOME/.local"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
LOCAL_PREFIX="$HOME/.local"
BIN_DIR="$LOCAL_PREFIX/bin"
LIB_DIR="$LOCAL_PREFIX/lib"
SHARE_DIR="$LOCAL_PREFIX/share"
SRC_DIR="$LOCAL_PREFIX/src/python"
mkdir -p "$PREFIX/bin"
PY_VERSIONS="
1|3.6.15
2|3.7.17
3|3.8.19
4|3.9.19
5|3.10.14
6|3.11.9
7|3.12.3
8|3.13.5
9|3.14.0a6
"
printf '╭────────────────────────────────────────────╮\n'
printf '│      Qompass AI · Python Quick‑Start       │\n'
printf '╰────────────────────────────────────────────╯\n'
printf '   © 2025 Qompass AI. All rights reserved   \n\n'
echo "Which Python version would you like to build?"
echo "$PY_VERSIONS" | while IFS="|" read num version; do
        [ -z "$num" ] && continue
        echo " $num) Python $version"
done
echo " a) All"
echo " q) Quit"
printf "Choose [8]: "
read -r choice
[ -z "$choice" ] && choice=8
[ "$choice" = "q" ] && exit 0
PY_FINALS_LIST="3.6.15 3.7.17 3.8.19 3.9.19 3.10.14 3.11.9 3.12.3 3.13.5 3.14.0a6"
if [ "$choice" = "a" ] || [ "$choice" = "A" ]; then
        VERSIONS_TO_BUILD="$PY_FINALS_LIST"
elif printf '%s\n' $PY_FINALS_LIST | awk "NR==$choice" | grep -q .; then
        VERSIONS_TO_BUILD=$(printf '%s\n' $PY_FINALS_LIST | awk "NR==$choice")
else
        echo "Invalid selection." >&2
        exit 1
fi
echo
echo "You selected: $VERSIONS_TO_BUILD"
echo "Which build configuration?"
echo " 1) Classic CPython"
echo " 2) Free-threaded (GIL-free, experimental)"
echo " 3) Classic with FULL OPTIMIZATIONS (PGO, LTO, LTO_FLAGS)"
echo " 4) Free-threaded + FULL OPTIMIZATIONS"
echo " q) Quit"
printf "Choose [1]: "
read -r cbuild
[ -z "$cbuild" ] && cbuild=1
[ "$cbuild" = "q" ] && exit 0
FREE_THREADED="no"
DO_OPTIMIZE="no"
case "$cbuild" in
2) FREE_THREADED="yes" ;;
3) DO_OPTIMIZE="yes" ;;
4)
        FREE_THREADED="yes"
        DO_OPTIMIZE="yes"
        ;;
esac
for PY_VERS in $VERSIONS_TO_BUILD; do
        PY_MAJ="$(echo "$PY_VERS" | cut -d. -f1-2)"
        cd "$SRC_DIR"
        if [ ! -d "cpython-$PY_VERS" ]; then
                echo "→ Cloning Python source (cpython $PY_VERS)..."
                git clone --branch "v$PY_VERS" https://github.com/python/cpython.git "cpython-$PY_VERS"
        fi
        cd "cpython-$PY_VERS"
        git fetch origin
        git checkout "v$PY_VERS"
        git clean -fdx
        echo "→ Configuring Python $PY_VERS build..."
        CONFIG_FLAGS="--prefix=$LOCAL_PREFIX"
        [ "$FREE_THREADED" = "yes" ] && CONFIG_FLAGS="$CONFIG_FLAGS --enable-free-threaded-interpreter"
        [ "$DO_OPTIMIZE" = "yes" ] && CONFIG_FLAGS="$CONFIG_FLAGS --enable-optimizations --with-lto"
        ./configure "$CONFIG_FLAGS"
        echo "→ Building Python $PY_VERS (this may take several minutes)..."
        export CFLAGS="-Wno-error=date-time"
        make -j"$(nproc)"
        echo "→ Installing Python $PY_VERS (no sudo needed)..."
        make install
done
case ":$PATH:" in *":$BIN_DIR:"*) ;; *) export PATH="$BIN_DIR:$PATH" ;; esac
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
PY_MAJ="$(echo "$PY_VERS" | cut -d. -f1-2)"
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
                for rc in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
                        if [ -f "$rc" ]; then
                                if ! grep -q "pyenv init" "$rc"; then
                                        printf "\n# Pyenv config\nexport PYENV_ROOT=\"%s\"\nexport PATH=\"\\\$PYENV_ROOT/bin:\\\$PATH\"\neval \"\\\$(pyenv init --path)\"\n" "$PYENV_ROOT" >>"$rc"
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
echo
echo "Would you like to install editor tooling for Python development?"
echo " 1) python-lsp-server (LSP support, compatible with most editors)"
echo " 2) pyright (Microsoft, static type checker/LSP, Node.js required)"
echo " 3) basedpyright (Rust-based, fast drop-in Pyright alternative, LSP)"
echo " 4) debugpy (VSCode-compatible debugger, works in editors/Jupyter)"
echo " 5) ipython (enhanced interactive Python prompt)"
echo " 6) pdbpp (better pdb, drop-in REPL/debugger)"
echo " a) All of the above"
echo " n) None (skip)"
printf "Choose [a]: "
read -r pytools_ans
[ -z "$pytools_ans" ] && pytools_ans="a"
INSTALL_LSP_TOOL() {
        tool="$1"
        pkg="$2"
        if [ "$tool" = "pyright" ]; then
                if command -v npm >/dev/null 2>&1; then
                        echo "→ Installing pyright (npm)..."
                        npm install -g pyright
                else
                        echo "npm not found, falling back to pipx/pip."
                        if command -v pipx >/dev/null 2>&1; then
                                pipx install pyright
                        else
                                "$PIP_PATH" install --user pyright
                        fi
                fi
        elif [ "$tool" = "basedpyright" ]; then
                if command -v pipx >/dev/null 2>&1; then
                        echo "→ Installing basedpyright (pipx)..."
                        pipx install basedpyright
                else
                        "$PIP_PATH" install --user basedpyright
                fi
        else
                echo "→ Installing $tool..."
                "$PIP_PATH" install --user "$pkg"
        fi
}
case "$pytools_ans" in
1) INSTALL_LSP_TOOL "python-lsp-server" "python-lsp-server[all]" ;;
2) INSTALL_LSP_TOOL "pyright" "pyright" ;;
3) INSTALL_LSP_TOOL "basedpyright" "basedpyright" ;;
4) INSTALL_LSP_TOOL "debugpy" "debugpy" ;;
5) INSTALL_LSP_TOOL "ipython" "ipython" ;;
6) INSTALL_LSP_TOOL "pdbpp" "pdbpp" ;;
a | A)
        INSTALL_LSP_TOOL "python-lsp-server" "python-lsp-server[all]"
        INSTALL_LSP_TOOL "pyright" "pyright"
        INSTALL_LSP_TOOL "basedpyright" "basedpyright"
        INSTALL_LSP_TOOL "debugpy" "debugpy"
        INSTALL_LSP_TOOL "ipython" "ipython"
        INSTALL_LSP_TOOL "pdbpp" "pdbpp"
        ;;
n | N) echo "Skipping extra tooling." ;;
*) echo "Unknown selection, skipping." ;;
esac
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
echo "✅ Python $VERSIONS_TO_BUILD has been built and installed in $BIN_DIR"
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
echo "→ To uninstall, just rm -rf $LOCAL_PREFIX/{bin/lib/share} $SRC_DIR/cpython-* ~/.pyenv ~/.cache/ruff ~/.cache/uv $XDG_CONFIG_HOME/ruff $XDG_CONFIG_HOME/uv"
echo "─ Ready, Set, Python! ─"
exit 0
