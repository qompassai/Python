#!/usr/bin/env bash
# /qompassai/python/scripts/setup.sh
# Copyright (C) 2025 Qompass AI, All rights reserved
# -------------------------------------
set -euo pipefail

echo "Creating Python environment directories..."
mkdir -p "$HOME/.cache/black"
mkdir -p "$HOME/.cache/huggingface"
mkdir -p "$HOME/.cache/mypy"
mkdir -p "$HOME/.cache/numba"
mkdir -p "$HOME/.cache/poetry"
mkdir -p "$HOME/.cache/pre-commit"
mkdir -p "$HOME/.cache/pytest"
mkdir -p "$HOME/.cache/torch"
mkdir -p "$HOME/.config/ipython"
mkdir -p "$HOME/.config/jupyter"
mkdir -p "$HOME/.config/matplotlib"
mkdir -p "$HOME/.config"
mkdir -p "$HOME/.local/share/poetry"
mkdir -p "$HOME/.virtualenvs"
PYTHON_VERSION=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
mkdir -p "$HOME/.local/lib/python${PYTHON_VERSION}/site-packages"
chmod 755 "$HOME/.cache" "$HOME/.config" "$HOME/.local" "$HOME/.virtualenvs" 2>/dev/null || true
chmod -R 755 "$HOME/.cache"/* "$HOME/.config"/* "$HOME/.local"/* 2>/dev/null || true
if [[ ! -f "$HOME/.config/pythonrc.py" ]]; then
    cat >"$HOME/.config/pythonrc.py" <<'EOF'
# Python startup configuration
import sys
import os
try:
    import readline
    import rlcompleter
    readline.parse_and_bind("tab: complete")
except ImportError:
    pass

# Add current directory to path if not already there
if '.' not in sys.path:
    sys.path.insert(0, '.')

print(f"Python {sys.version} on {sys.platform}")
print(f"PYTHONPATH: {os.environ.get('PYTHONPATH', 'Not set')}")
EOF
    echo "Created $HOME/.config/pythonrc.py"
fi
echo "✅ All Python environment directories created successfully!"
echo "✅ Python startup file created at $HOME/.config/pythonrc.py"
echo ""
echo "Created directories:"
echo "  📁 Cache: ~/.cache/{black,huggingface,mypy,numba,poetry,pre-commit,pytest,torch}"
echo "  📁 Config: ~/.config/{ipython,jupyter,matplotlib}"
echo "  📁 Local: ~/.local/share/poetry"
echo "  📁 Python: ~/.local/lib/python${PYTHON_VERSION}/site-packages"
echo "  📁 Virtual envs: ~/.virtualenvs"
