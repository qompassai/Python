# /qompassai/nix/flake.nix
# Qompass AI python setup flake
# Copyright (C) 2025 Qompass AI, All rights reserved
# ---------------------------------------------------
{
  description = "Comprehensive development environment with Python, networking, and formatting tools";

  inputs = {
    flake-compat.url = "github:edolstra/flake-compat";
    flake-compat.flake = false;
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };

        pythonEnvSetup = pkgs.writeShellScriptBin "python-env-setup" ''
          #!/usr/bin/env bash
          set -euo pipefail
          
          echo "🐍 Setting up Python development environment..."
          
          # Create necessary directories
          mkdir -p ~/.config/{pip,python}
          mkdir -p ~/.cache/{pip,mypy,pytest,black,pre-commit}
          mkdir -p ~/.local/{lib,share,bin}
          mkdir -p ~/.virtualenvs
          
          # Create pip.conf optimized for development
          cat > ~/.config/pip/pip.conf << 'EOF'
[global]
break-system-packages = false
cache-dir = ~/.cache/pip
cert = /etc/ssl/certs/ca-certificates.crt
disable-pip-version-check = true
index-url = https://pypi.org/simple/
log = ~/.cache/pip/pip.log
no-build-isolation = false
prefer-binary = true
progress-bar = on
require-hashes = false
retries = 5
timeout = 300
trusted-host = pypi.org
               pypi.python.org
               files.pythonhosted.org

[install]
upgrade-strategy = eager

[freeze]
all = true
EOF
          
          # Create Python startup file
          cat > ~/.config/python/pythonrc.py << 'EOF'
# Python startup configuration
import sys
import os

try:
    import readline
    import rlcompleter
    readline.parse_and_bind("tab: complete")
except ImportError:
    pass

if '.' not in sys.path:
    sys.path.insert(0, '.')

print(f"Python {sys.version} on {sys.platform}")
print(f"PYTHONPATH: {os.environ.get('PYTHONPATH', 'Not set')}")
EOF
          
          chmod 600 ~/.config/pip/pip.conf
          chmod 644 ~/.config/python/pythonrc.py
          
          echo "✅ Python environment configured"
        '';

      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            python312
            python312Packages.pip
            python312Packages.setuptools
            python312Packages.wheel
            age
            alejandra
            b3sum
            bash
            biome
            black
            curl
            dig
            dprint
            git
            gnupg
            isort
            jq
            lua
            mdformat
            nix
            nixfmt-classic
            nmap
            nodejs_22
            openssl_3
            pinentry
            python312Packages.ruff
            rage
            rhash
            ruff
            rustc
            rustfmt
            shfmt
            stylua
            taplo
            tmux
            unbound
            vim
            wget
            wireshark-cli
            yamlfix
            yubikey-manager
          ];

          shellHook = ''
            echo "🚀 Development Environment Ready"
            echo "================================"
            echo "🐍 Python: $(python3 --version)"
            echo "📦 Node.js: $(node --version)"
            echo "🦀 Rust: $(rustc --version)"
            echo "❄️  Nix: $(nix --version | head -1)"
            echo ""
            echo "Available formatters:"
            echo "  • alejandra (Nix)"
            echo "  • biome (JS/TS/JSON)"
            echo "  • black (Python)"
            echo "  • mdformat (Markdown)"
            echo "  • ruff (Python)"
            echo "  • rustfmt (Rust)"
            echo "  • shfmt (Shell)"
            echo "  • stylua (Lua)"
            echo "  • taplo (TOML)"
            echo "  • yamlfix (YAML)"
            echo ""
            echo "Security tools:"
            echo "  • age/rage (encryption)"
            echo "  • openssl (cryptography)"
            echo "  • unbound (DNS security)"
            echo "  • yubikey-manager (hardware keys)"
            echo ""
            echo "Run 'python-env-setup' to configure Python environment"
          '';

          PYTHON = "python3";
          PYTHONBREAKPOINT = "pdb.set_trace";
          PYTHONDONTWRITEBYTECODE = "1";
          PYTHONFAULTHANDLER = "1";
          PYTHONHASHSEED = "random";
          PYTHONIOENCODING = "utf-8";
          PYTHONUNBUFFERED = "1";
          PYTHONWARNINGS = "ignore::DeprecationWarning";
          VIRTUAL_ENV_DISABLE_PROMPT = "1";
          WORKON_HOME = "$HOME/.virtualenvs";
        };

        packages = {
          default = pythonEnvSetup;
           neovim-configured = nixvim.legacyPackages.${system}.makeNixvim {
    colorschemes.gruvbox.enable = true;

    plugins.conform-nvim = {
      enable = true;
      settings = {
        formatters_by_ft = {
          "_" = [ "trim_whitespace" ];
          css = [ "biome" ];
          html = [ "biome" ];
          javascript = [ "biome" ];
          javascriptreact = [ "biome" ];
          json = [ "biome" ];
          jsonc = [ "biome" ];
          lua = [ "stylua" ];
          markdown = [ "mdformat" ];
          nix = [ "alejandra" ];
          python = [ "ruff" "black" ];
          rust = [ "rustfmt" ];
          sh = [ "shfmt" ];
          toml = [ "taplo" ];
          tsx = [ "biome" ];
          typescript = [ "biome" ];
          typescriptreact = [ "biome" ];
          yaml = [ "yamlfix" ];
          yml = [ "yamlfix" ];
        };
        formatters = {
          alejandra = { stdin = true; };
          biome = {
            command = "biome";
            args = [ "format" "--stdin-file-path" "$FILENAME" ];
            stdin = true;
          };
          mdformat = {
            command = "mdformat";
            args = [ "--wrap" "160" ];
            stdin = true;
          };
          ruff = {
            command = "ruff";
            args = [ "format" "--stdin-filename" "$FILENAME" "-" ];
            stdin = true;
          };
          shfmt = {
            command = "shfmt";
            args = [ "-i" "2" "-ci" "-" ];
            stdin = true;
          };
          stylua = {
            prepend_args = [ "--indent-type" "Spaces" "--indent-width" "2" ];
          };
          yamlfix = {
            command = "yamlfix";
            args = [ "-" ];
            stdin = true;
          };
        };
      };
    };
    
    plugins.telescope.enable = true;
    plugins.treesitter.enable = true;
    plugins.lsp.enable = true;
  };
  
  dev-env-check = pkgs.writeShellScriptBin "dev-env-check" ''
          conform-config = pkgs.writeText "conform.lua" ''
            return {
              "stevearc/conform.nvim",
              opts = {
                formatters_by_ft = {
                  ["_"] = { "trim_whitespace" },
                  css = { "biome" },
                  html = { "biome" },
                  javascript = { "biome" },
                  javascriptreact = { "biome" },
                  json = { "biome" },
                  jsonc = { "biome" },
                  lua = { "stylua" },
                  markdown = { "mdformat" },
                  nix = { "alejandra" },
                  python = { "ruff", "black" },
                  rust = { "rustfmt" },
                  sh = { "shfmt" },
                  toml = { "taplo" },
                  tsx = { "biome" },
                  typescript = { "biome" },
                  typescriptreact = { "biome" },
                  yaml = { "yamlfix" },
                  yml = { "yamlfix" },
                },
                formatters = {
                  alejandra = { stdin = true },
                  biome = {
                    command = "biome",
                    args = { "format", "--stdin-file-path", "$FILENAME" },
                    stdin = true,
                  },
                  mdformat = {
                    command = "mdformat",
                    args = { "--wrap", "160" },
                    stdin = true,
                  },
                  ruff = {
                    command = "ruff",
                    args = { "format", "--stdin-filename", "$FILENAME", "-" },
                    stdin = true,
                  },
                  shfmt = {
                    command = "shfmt",
                    args = { "-i", "2", "-ci", "-" },
                    stdin = true,
                  },
                  stylua = {
                    prepend_args = { "--indent-type", "Spaces", "--indent-width", "2" },
                  },
                  yamlfix = {
                    command = "yamlfix",
                    args = { "-" },
                    stdin = true,
                  },
                },
              },
            }
          '';

          dev-env-check = pkgs.writeShellScriptBin "dev-env-check" ''
            #!/usr/bin/env bash
            echo "🔍 Development Environment Check"
            echo "================================"
            
            echo "📝 Formatters:"
            command -v alejandra >/dev/null && echo "  ✅ alejandra" || echo "  ❌ alejandra"
            command -v biome >/dev/null && echo "  ✅ biome" || echo "  ❌ biome"
            command -v black >/dev/null && echo "  ✅ black" || echo "  ❌ black"
            command -v mdformat >/dev/null && echo "  ✅ mdformat" || echo "  ❌ mdformat"
            command -v ruff >/dev/null && echo "  ✅ ruff" || echo "  ❌ ruff"
            command -v rustfmt >/dev/null && echo "  ✅ rustfmt" || echo "  ❌ rustfmt"
            command -v shfmt >/dev/null && echo "  ✅ shfmt" || echo "  ❌ shfmt"
            command -v stylua >/dev/null && echo "  ✅ stylua" || echo "  ❌ stylua"
            command -v taplo >/dev/null && echo "  ✅ taplo" || echo "  ❌ taplo"
            command -v yamlfix >/dev/null && echo "  ✅ yamlfix" || echo "  ❌ yamlfix"
            
            echo ""
            echo "🐍 Python Environment:"
            python3 --version
            pip --version
            echo "PYTHONPATH: $PYTHONPATH"
            echo "Virtual envs: $WORKON_HOME"
            
            echo ""
            echo "🔐 Security Tools:"
            openssl version
            command -v rage >/dev/null && rage --version || echo "rage not found"
            command -v age >/dev/null && age --version || echo "age not found"
          '';
          network-security-setup = pkgs.writeShellScriptBin "network-security-setup" ''
            #!/usr/bin/env bash
            set -euo pipefail
            
            echo "🔐 Setting up network security tools..."
            
            mkdir -p ~/.config/{rage,unbound,ssl}
            mkdir -p ~/.cache/{unbound,ssl}
            
            if [[ ! -f ~/.config/rage/key.txt ]]; then
              echo "🔑 Generating rage encryption key..."
              ${pkgs.rage}/bin/rage-keygen -o ~/.config/rage/key.txt
              chmod 600 ~/.config/rage/key.txt
              echo "✅ Rage key generated"
            fi
            
            echo "📋 Your rage public key:"
            ${pkgs.rage}/bin/rage-keygen -y ~/.config/rage/key.txt
            
            echo "✅ Network security setup complete"
          '';

          python-env-setup = pythonEnvSetup;

          tool-installer = pkgs.writeShellScriptBin "tool-installer" ''
            echo "📦 Installing additional development tools via pip/npm..."
            
            pip install --user --upgrade \
              ruff \
              black \
              isort \
              mypy \
              pytest \
              pre-commit \
              mdformat \
              yamlfix
            
            npm install -g \
              @biomejs/biome \
              prettier \
              eslint \
              typescript
            
            echo "✅ Additional tools installed"
          '';
        };

        formatter-configs = {
          biome = pkgs.writeText "biome.json" ''
            {
              "$schema": "https://biomejs.dev/schemas/1.4.1/schema.json",
              "formatter": {
                "enabled": true,
                "formatWithErrors": false,
                "indentStyle": "space",
                "indentSize": 2,
                "lineWidth": 160
              },
              "linter": {
                "enabled": true,
                "rules": {
                  "recommended": true
                }
              },
              "javascript": {
                "formatter": {
                  "quoteStyle": "double",
                  "semicolons": "always"
                }
              }
            }
          '';
          
          ruff = pkgs.writeText "ruff.toml" ''
            [tool.ruff]
            line-length = 88
            target-version = "py312"
            
            [tool.ruff.format]
            quote-style = "double"
            indent-style = "space"
            
            [tool.ruff.lint]
            select = ["E", "F", "W", "I", "N", "UP", "ANN", "S", "B", "A", "COM", "C4", "DTZ", "T10", "ISC", "ICN", "PIE", "PT", "RSE", "RET", "SIM", "TID", "ARG", "PLE", "PLR", "PLW", "TRY", "NPY", "RUF"]
          '';
        };
      }
    );
}

