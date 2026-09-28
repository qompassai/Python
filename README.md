<!--/qompassai/python/README.md -->
<!-- ------------------------------ -->
<!-- Copyright (C) 2025 Qompass AI, All rights reserved -->

<h2> Python: The OG of AI </h2>

<h3> Qompass AI on Python </h3>

![Repository Views](https://komarev.com/ghpvc/?username=qompassai-python)
![GitHub all releases](https://img.shields.io/github/downloads/qompassai/python/total?style=flat-square)

<p align="center">
  <a href="https://www.python.org/">
  <img src="https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white" alt="Python">
</a>
<br>
<a href="https://docs.python.org/3/">
  <img src="https://img.shields.io/badge/Python_Documentation-blue?style=flat-square" alt="Python Documentation">
</a>
<a href="https://github.com/topics/python-tutorial">
  <img src="https://img.shields.io/badge/Python_Tutorials-green?style=flat-square" alt="Python Tutorials">
</a>
<br>
  <a href="./LICENSE"><img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg" alt="License: Apache 2.0"></a>
</p>

<details>
  <summary style="font-size: 1.4em; font-weight: bold; padding: 15px; background: #667eea; color: white; border-radius: 10px; cursor: pointer; margin: 10px 0;">
    <strong>
      <img src="https://raw.githubusercontent.com/qompassai/svg/main/assets/icons/python/python.svg"
           alt="Qmopass AI Python Logo"
           style="height: 1em; vertical-align: -0.2em; margin-right: 0.25em;" />
      Python Solutions     </strong>
  </summary>
  <div style="background: #f8f9fa; padding: 15px; border-radius: 5px; margin-top: 10px; font-family: monospace;">

* [Qompass Radar](https://github.com/qompassai/radar)    
* [Qompass Qonfig](https://github.com/qompassai/qonfig)

  </div>

<details>
  <summary style="font-size: 1.4em; font-weight: bold; padding: 15px; background: #667eea; color: white; border-radius: 10px; cursor: pointer; margin: 10px 0;">
    <strong>
      <img src="https://raw.githubusercontent.com/qompassai/svg/main/assets/icons/edu/edu.svg"
           alt="Ferris the Crab"
           style="height: 1em; vertical-align: -0.2em; margin-right: 0.25em;" />
      Educational Videos
    </strong>
  </summary>
  <div style="background: #f8f9fa; padding: 15px; border-radius: 5px; margin-top: 10px; font-family: monospace;">

  [![Making Python useful for AI datasets](https://img.youtube.com/vi/T-XGHgaJIPU/hqdefault.jpg)](https://www.youtube.com/watch?v=T-XGHgaJIPU&t=511s)

  </div>

</details>
</details>

  <details>
  <summary style="font-size: 1.4em; font-weight: bold; padding: 15px; background: #667eea; color: white; border-radius: 10px; cursor: pointer; margin: 10px 0;">
    <strong>▶️ Qompass AI Quick Start</strong>
  </summary>
  <div style="background: #f8f9fa; padding: 15px; border-radius: 5px; margin-top: 10px; font-family: monospace;">

```sh  
curl -fsSL https://raw.githubusercontent.com/qompassai/python/main/scripts/quickstart.sh | sh
```
  </div>
  <blockquote style="font-size: 1.2em; line-height: 1.8; padding: 25px; background: #f8f9fa; border-left: 6px solid #667eea; border-radius: 8px; margin: 15px 0; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">
    <details>
      <summary style="font-size: 1em; font-weight: bold; padding: 10px; background: #e9ecef; color: #333; border-radius: 5px; cursor: pointer; margin: 10px 0;">
        <strong>📄 We advise you read the script BEFORE running it 😉</strong>
      </summary>
      <pre style="background: #fff; padding: 15px; border-radius: 5px; border: 1px solid #ddd; overflow-x: auto;">
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
exit 0 </pre>
</details> <p>Or, <a href="https://github.com/qompassai/python/blob/main/scripts/quickstart.sh" target="_blank">View
the quickstart script</a>.</p>
 </details>

  </blockquote>
  </details>

  <details>
    <summary
      style="font-size: 1.4em; font-weight: bold; padding: 15px; background: #667eea; color: white; border-radius: 10px; cursor: pointer; margin: 10px 0;">
      <strong>🧭 About Qompass AI</strong>
    </summary>
    <blockquote
      style="font-size: 1.2em; line-height: 1.8; padding: 25px; background: #f8f9fa; border-left: 6px solid #667eea; border-radius: 8px; margin: 15px 0; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">
    <div align="center">
    <p>Matthew A. Porter<br>
      Former Intelligence Officer<br>
      Educator & Learner<br>
      DeepTech Founder & CEO</p>
  </div>

  <h3>Publications</h3>
  <p>
    <a href="https://orcid.org/0000-0002-0302-4812">
      <img src="https://img.shields.io/badge/ORCID-0000--0002--0302--4812-green?style=flat-square&logo=orcid"
        alt="ORCID">
    </a>
    <a href="https://www.researchgate.net/profile/Matt-Porter-7">
      <img src="https://img.shields.io/badge/ResearchGate-Open--Research-blue?style=flat-square&logo=researchgate"
        alt="ResearchGate">
    </a>
    <a href="https://zenodo.org/communities/qompassai">
      <img src="https://img.shields.io/badge/Zenodo-Publications-blue?style=flat-square&logo=zenodo" alt="Zenodo">
    </a>
  </p>

  <h3>Developer Programs</h3>

[![NVIDIA
Developer](https://img.shields.io/badge/NVIDIA-Developer_Program-76B900?style=for-the-badge\&logo=nvidia\&logoColor=white)](https://developer.nvidia.com/)
[![Meta
Developer](https://img.shields.io/badge/Meta-Developer_Program-0668E1?style=for-the-badge\&logo=meta\&logoColor=white)](https://developers.facebook.com/)
[![HackerOne](https://img.shields.io/badge/-HackerOne-%23494649?style=for-the-badge\&logo=hackerone\&logoColor=white)](https://hackerone.com/phaedrusflow)
[![HuggingFace](https://img.shields.io/badge/HuggingFace-qompass-yellow?style=flat-square\&logo=huggingface)](https://huggingface.co/qompass)
[![Epic Games
Developer](https://img.shields.io/badge/Epic_Games-Developer_Program-313131?style=for-the-badge\&logo=epic-games\&logoColor=white)](https://dev.epicgames.com/)

  <h3>Professional Profiles</h3>
  <p>
    <a href="https://www.linkedin.com/in/matt-a-porter-103535224/">
      <img src="https://img.shields.io/badge/LinkedIn-Matt--Porter-blue?style=flat-square&logo=linkedin"
        alt="Personal LinkedIn">
    </a>
    <a href="https://www.linkedin.com/company/95058568/">
      <img src="https://img.shields.io/badge/LinkedIn-Qompass--AI-blue?style=flat-square&logo=linkedin"
        alt="Startup LinkedIn">
    </a>
  </p>

  <h3>Social Media</h3>
  <p>
    <a href="https://twitter.com/PhaedrusFlow">
      <img src="https://img.shields.io/badge/Twitter-@PhaedrusFlow-blue?style=flat-square&logo=twitter"
        alt="X/Twitter">
    </a>
    <a href="https://www.instagram.com/phaedrusflow">
      <img src="https://img.shields.io/badge/Instagram-phaedrusflow-purple?style=flat-square&logo=instagram"
        alt="Instagram">
    </a>
    <a href="https://www.youtube.com/@qompassai">
      <img src="https://img.shields.io/badge/YouTube-QompassAI-red?style=flat-square&logo=youtube"
        alt="Qompass AI YouTube">
    </a>
  </p>

</blockquote>

  </details>

  <details>
    <summary
      style="font-size: 1.4em; font-weight: bold; padding: 15px; background: #ff6b6b; color: white; border-radius: 10px; cursor: pointer; margin: 10px 0;">
      <strong>🔥 How Do I Support</strong>
    </summary>
    <blockquote
      style="font-size: 1.2em; line-height: 1.8; padding: 25px; background: #fff5f5; border-left: 6px solid #ff6b6b; border-radius: 8px; margin: 15px 0; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">
  <div align="center">
    <table>
      <tr>
        <th align="center">🏛️ Qompass AI Pre-Seed Funding 2023-2025</th>
        <th align="center">🏆 Amount</th>
        <th align="center">📅 Date</th>
      </tr>
      <tr>
        <td><a href="https://github.com/qompassai/r4r"
            title="RJOS/Zimmer Biomet Research Grant Repository">RJOS/Zimmer Biomet Research Grant</a></td>
        <td align="center">$30,000</td>
        <td align="center">March 2024</td>
      </tr>
      <tr>
        <td><a href="https://github.com/qompassai/PathFinders" title="GitHub Repository">Pathfinders Intern
            Program</a><br>
          <small><a
              href="https://www.linkedin.com/posts/evergreenbio_bioscience-internships-workforcedevelopment-activity-7253166461416812544-uWUM/"
              target="_blank">View on LinkedIn</a></small>
        </td>
        <td align="center">$2,000</td>
        <td align="center">October 2024</td>
      </tr>
    </table>
    <br>
    <h4>🤝 How To Support Our Mission</h4>
    [![GitHub
    Sponsors](https://img.shields.io/badge/GitHub-Sponsor-EA4AAA?style=for-the-badge\&logo=github-sponsors\&logoColor=white)](https://github.com/sponsors/phaedrusflow)
    [![Patreon](https://img.shields.io/badge/Patreon-Support-F96854?style=for-the-badge\&logo=patreon\&logoColor=white)](https://patreon.com/qompassai)
    [![Liberapay](https://img.shields.io/badge/Liberapay-Donate-F6C915?style=for-the-badge\&logo=liberapay\&logoColor=black)](https://liberapay.com/qompassai)
    [![Open
    Collective](https://img.shields.io/badge/Open%20Collective-Support-7FADF2?style=for-the-badge\&logo=opencollective\&logoColor=white)](https://opencollective.com/qompassai)
    [![Buy Me A
    Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-Support-FFDD00?style=for-the-badge\&logo=buy-me-a-coffee\&logoColor=black)](https://www.buymeacoffee.com/phaedrusflow)
    <details markdown="1">
      <summary><strong>🔐 Cryptocurrency Donations</strong></summary>
      **Monero (XMR):**
      <div align="center">
        <img src="https://github.com/qompassai/svg/assets/monero-qr.svg" alt="Monero QR Code" width="180">
      </div>
  <div style="margin: 10px 0;">
    <code>42HGspSFJQ4MjM5ZusAiKZj9JZWhfNgVraKb1eGCsHoC6QJqpo2ERCBZDhhKfByVjECernQ6KeZwFcnq8hVwTTnD8v4PzyH</code>
  </div>

<button
onclick="navigator.clipboard.writeText('42HGspSFJQ4MjM5ZusAiKZj9JZWhfNgVraKb1eGCsHoC6QJqpo2ERCBZDhhKfByVjECernQ6KeZwFcnq8hVwTTnD8v4PzyH')"
style="padding: 6px 12px; background: #FF6600; color: white; border: none; border-radius: 4px; cursor: pointer;">
📋 Copy Address </button>

  <p><i>Funding helps us continue our research at the intersection of AI, healthcare, and education</i></p>

</blockquote>

  </details>
  </details>

  <details id="FAQ">
    <summary><strong>Frequently Asked Questions</strong></summary>
### Q: How do you mitigate against bias?

**TLDR - we do math to make AI ethically useful**

### A: We delineate between mathematical bias (MB) - a fundamental parameter in neural network equations - and

algorithmic/social bias (ASB). While MB is optimized during model training through backpropagation, ASB requires
careful consideration of data sources, model architecture, and deployment strategies. We implement attention
mechanisms for improved input processing and use legal open-source data and secure web-search APIs to help mitigate
ASB.

[AAMC AI Guidelines | One way to align AI against
ASB](https://www.aamc.org/about-us/mission-areas/medical-education/principles-ai-use)

### AI Math at a glance

## Forward Propagation Algorithm

$$
y = w\_1x\_1 + w\_2x\_2 + ... + w\_nx\_n + b
$$

Where:

* $y$ represents the model output
* $(x\_1, x\_2, ..., x\_n)$ are input features
* $(w\_1, w\_2, ..., w\_n)$ are feature weights
* $b$ is the bias term

### Neural Network Activation

For neural networks, the bias term is incorporated before activation:

$$
z = \sum\_{i=1}^{n} w\_ix\_i + b
$$
$$
a = \sigma(z)
$$

Where:

* $z$ is the weighted sum plus bias
* $a$ is the activation output
* $\sigma$ is the activation function

### Attention Mechanism- aka what makes the Transformer (The "T" in ChatGPT) powerful

* [Attention High level overview video](https://www.youtube.com/watch?v=fjJOgb-E41w)

* [Attention Is All You Need Arxiv Paper](https://arxiv.org/abs/1706.03762)

The Attention mechanism equation is:

$$
\text{Attention}(Q, K, V) = \text{softmax}\left( \frac{QK^T}{\sqrt{d\_k}} \right) V
$$

Where:

* $Q$ represents the Query matrix
* $K$ represents the Key matrix
* $V$ represents the Value matrix
* $d\_k$ is the dimension of the key vectors
* $\text{softmax}(\cdot)$ normalizes scores to sum to 1

### Q: Do I have to buy a Linux computer to use this? I don't have time for that!

### A: No. You can run Linux and/or the tools we share alongside your existing operating system:

* Windows users can use Windows Subsystem for Linux [WSL](https://learn.microsoft.com/en-us/windows/wsl/install)
* Mac users can use [Homebrew](https://brew.sh/)
* The code-base instructions were developed with both beginners and advanced users in mind.

### Q: Do you have to get a masters in AI?

### A: Not if you don't want to. To get competent enough to get past ChatGPT dependence at least, you just need a

computer and a beginning's mindset. Huggingface is a good place to start.

* [Huggingface](https://docs.google.com/presentation/d/1IkzESdOwdmwvPxIELYJi8--K3EZ98_cL6c5ZcLKSyVg/edit#slide=id.p)

### Q: What makes a "small" AI model?

### A: AI models ~=10 billion(10B) parameters and below. For comparison, OpenAI's GPT4o contains approximately 200B parameters.

  </details>

## License

This project is licensed under the [Apache License, Version 2.0](./LICENSE).

Copyright 2025 Qompass AI.

