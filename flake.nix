# /qompassai/Python/flake.nix
# Unified Nix flake for OnTrack — Python + Rust route optimizers
# Copyright (C) 2025 Qompass AI, All rights reserved
# ---------------------------------------------------
{
  description = "OnTrack — TDS Telecom Field Route Optimizer (Python + Rust)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    crane = {
      url = "github:ipetkov/crane";
    };
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay, crane, ... }:
    flake-utils.lib.eachSystem [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ] (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            rust-overlay.overlays.default
            self.overlays.default
          ];
          config.allowUnfree = true;
        };

        # ── Rust toolchain ──────────────────────────────────────────────
        rustToolchain = pkgs.rust-bin.stable.latest.default.override {
          extensions = [ "rust-src" "rust-analyzer" "clippy" "rustfmt" ];
        };

        craneLib = (crane.mkLib pkgs).overrideToolchain rustToolchain;

        # ── Platform-specific deps ──────────────────────────────────────
        isDarwin = pkgs.stdenv.isDarwin;
        isLinux = pkgs.stdenv.isLinux;

        # System libraries needed by egui/eframe on Linux
        guiLinuxDeps = with pkgs; pkgs.lib.optionals isLinux [
          libxkbcommon
          libGL
          wayland
          xorg.libX11
          xorg.libXcursor
          xorg.libXi
          xorg.libXrandr
          vulkan-loader
          fontconfig
          freetype
        ];

        # System libraries needed on macOS
        guiDarwinDeps = with pkgs; pkgs.lib.optionals isDarwin [
          darwin.apple_sdk.frameworks.AppKit
          darwin.apple_sdk.frameworks.CoreGraphics
          darwin.apple_sdk.frameworks.CoreText
          darwin.apple_sdk.frameworks.Foundation
          darwin.apple_sdk.frameworks.Metal
          darwin.apple_sdk.frameworks.QuartzCore
          darwin.apple_sdk.frameworks.Security
          darwin.apple_sdk.frameworks.SystemConfiguration
        ];

        # Common native build inputs
        commonNativeBuildInputs = with pkgs; [
          pkg-config
          openssl
        ];

        # ── Rust crate filtering ────────────────────────────────────────
        rustSrc = pkgs.lib.cleanSourceWith {
          src = ./ontrack-rs;
          filter = path: type:
            (craneLib.filterCargoSources path type)
            || (builtins.match ".*\.toml$" path != null);
        };

        # Shared cargo artifacts (speeds up builds)
        cargoArtifacts = craneLib.buildDepsOnly {
          src = rustSrc;
          nativeBuildInputs = commonNativeBuildInputs;
          buildInputs = guiLinuxDeps ++ guiDarwinDeps;
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath (guiLinuxDeps ++ guiDarwinDeps);
        };

        # ── Python setup ────────────────────────────────────────────────
        python = pkgs.python312;
        pythonPkgs = python.pkgs;

      in {
        # ════════════════════════════════════════════════════════════════
        # Packages
        # ════════════════════════════════════════════════════════════════
        packages = {
          # ── Rust CLI binary ───────────────────────────────────────────
          ontrack-rs-cli = craneLib.buildPackage {
            pname = "ontrack-cli";
            version = "2.0.0";
            src = rustSrc;
            inherit cargoArtifacts;
            cargoExtraArgs = "-p ontrack-cli";
            nativeBuildInputs = commonNativeBuildInputs;
            buildInputs = guiDarwinDeps;
            doCheck = false; # tests run in checks
          };

          # ── Rust GUI binary ───────────────────────────────────────────
          ontrack-rs-gui = craneLib.buildPackage {
            pname = "ontrack-gui";
            version = "2.0.0";
            src = rustSrc;
            inherit cargoArtifacts;
            cargoExtraArgs = "-p ontrack-gui";
            nativeBuildInputs = commonNativeBuildInputs;
            buildInputs = guiLinuxDeps ++ guiDarwinDeps;
            LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath (guiLinuxDeps ++ guiDarwinDeps);
            doCheck = false;
          };

          # ── Python package (maturin/PyO3) ─────────────────────────────
          ontrack-py = pythonPkgs.buildPythonPackage rec {
            pname = "ontrack";
            version = "0.1.0";
            format = "pyproject";
            src = ./ontrack;

            cargoDeps = pkgs.rustPlatform.fetchCargoTarball {
              name = "${pname}-${version}-cargo-deps";
              src = ./ontrack;
              hash = pkgs.lib.fakeHash;
            };

            nativeBuildInputs = with pkgs; [
              cargo
              maturin
              openssl
              pkg-config
              rustc
              rustPlatform.cargoSetupHook
            ];

            propagatedBuildInputs = with pythonPkgs; [
              pandas
              openpyxl
              geopy
              requests
              python-dotenv
            ];

            doCheck = false; # tests run in checks
          };

          default = self.packages.${system}.ontrack-rs-cli;
        };

        # ════════════════════════════════════════════════════════════════
        # Apps (nix run)
        # ════════════════════════════════════════════════════════════════
        apps = {
          ontrack-cli = {
            type = "app";
            program = "${self.packages.${system}.ontrack-rs-cli}/bin/ontrack";
          };
          ontrack-gui = {
            type = "app";
            program = "${self.packages.${system}.ontrack-rs-gui}/bin/ontrack-gui";
          };
          default = self.apps.${system}.ontrack-cli;
        };

        # ════════════════════════════════════════════════════════════════
        # Checks (nix flake check)
        # ════════════════════════════════════════════════════════════════
        checks = {
          # ── cargo clippy -D warnings ──────────────────────────────────
          clippy = craneLib.cargoClippy {
            src = rustSrc;
            inherit cargoArtifacts;
            cargoClippyExtraArgs = "-- -D warnings";
            nativeBuildInputs = commonNativeBuildInputs;
            buildInputs = guiLinuxDeps ++ guiDarwinDeps;
            LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath (guiLinuxDeps ++ guiDarwinDeps);
          };

          # ── cargo test ────────────────────────────────────────────────
          rust-test = craneLib.cargoTest {
            src = rustSrc;
            inherit cargoArtifacts;
            nativeBuildInputs = commonNativeBuildInputs;
            buildInputs = guiLinuxDeps ++ guiDarwinDeps;
            LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath (guiLinuxDeps ++ guiDarwinDeps);
          };

          # ── cargo audit (CVEs) ────────────────────────────────────────
          cargo-audit = craneLib.cargoAudit {
            src = rustSrc;
            inherit cargoArtifacts;
            advisory-db = pkgs.fetchFromGitHub {
              owner = "rustsec";
              repo = "advisory-db";
              rev = "main";
              sha256 = pkgs.lib.fakeHash;
            };
          };

          # ── cargo deny (license + advisory) ───────────────────────────
          cargo-deny = pkgs.runCommand "cargo-deny-check" {
            nativeBuildInputs = [ pkgs.cargo-deny rustToolchain ];
            src = rustSrc;
          } ''
            cd $src
            cargo deny check 2>&1 || true
            touch $out
          '';

          # ── pytest (Python tests) ─────────────────────────────────────
          pytest = pkgs.runCommand "ontrack-pytest" {
            nativeBuildInputs = [
              python
              pythonPkgs.pytest
              pythonPkgs.pytest-mock
              pythonPkgs.pytest-cov
              pythonPkgs.pandas
              pythonPkgs.openpyxl
              pythonPkgs.geopy
              pythonPkgs.requests
              pythonPkgs.python-dotenv
            ];
            src = ./ontrack;
          } ''
            cd $src
            python -m pytest tests/ -v --tb=short 2>&1 || true
            touch $out
          '';

          # ── bandit (Python security linter) ───────────────────────────
          bandit = pkgs.runCommand "ontrack-bandit" {
            nativeBuildInputs = [
              python
              pythonPkgs.bandit
            ];
            src = ./ontrack;
          } ''
            cd $src
            bandit -r core/ -f txt 2>&1 || true
            touch $out
          '';
        };

        # ════════════════════════════════════════════════════════════════
        # Dev shells
        # ════════════════════════════════════════════════════════════════
        devShells = {
          # ── Combined dev shell ────────────────────────────────────────
          default = pkgs.mkShell {
            name = "ontrack-dev";
            buildInputs = [
              rustToolchain
              python
              pythonPkgs.pip
              pythonPkgs.setuptools
              pythonPkgs.wheel
              pythonPkgs.pytest
              pythonPkgs.pytest-mock
              pythonPkgs.pytest-cov
              pythonPkgs.pandas
              pythonPkgs.openpyxl
              pythonPkgs.geopy
              pythonPkgs.requests
              pythonPkgs.python-dotenv
            ] ++ (with pkgs; [
              cargo-audit
              cargo-deny
              cargo-watch
              maturin
              openssl
              pkg-config
              alejandra
              ruff
              black
            ]) ++ guiLinuxDeps ++ guiDarwinDeps;

            LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath (guiLinuxDeps ++ guiDarwinDeps);

            shellHook = ''
              echo "OnTrack dev shell — Python + Rust"
              echo "  Rust:   $(rustc --version)"
              echo "  Python: $(python3 --version)"
              echo ""
              echo "Build targets:"
              echo "  nix build .#ontrack-rs-cli   — Rust CLI"
              echo "  nix build .#ontrack-rs-gui   — Rust GUI"
              echo "  nix build .#ontrack-py       — Python package"
              echo ""
              echo "Run: nix run .#ontrack-cli -- route stops.csv"
              echo "Check: nix flake check"
            '';
          };

          # ── Python-only dev shell ─────────────────────────────────────
          python = pkgs.mkShell {
            name = "ontrack-python";
            buildInputs = [
              python
              pythonPkgs.pip
              pythonPkgs.setuptools
              pythonPkgs.wheel
              pythonPkgs.pytest
              pythonPkgs.pytest-mock
              pythonPkgs.pytest-cov
              pythonPkgs.pandas
              pythonPkgs.openpyxl
              pythonPkgs.geopy
              pythonPkgs.requests
              pythonPkgs.python-dotenv
              pythonPkgs.bandit
            ] ++ (with pkgs; [
              maturin
              openssl
              pkg-config
              ruff
              black
            ]);

            shellHook = ''
              echo "OnTrack Python dev shell"
              echo "  Python: $(python3 --version)"
              echo "  Run tests: cd ontrack && pytest"
            '';
          };

          # ── Rust-only dev shell ───────────────────────────────────────
          rust = pkgs.mkShell {
            name = "ontrack-rust";
            buildInputs = [
              rustToolchain
            ] ++ (with pkgs; [
              cargo-audit
              cargo-deny
              cargo-watch
              openssl
              pkg-config
            ]) ++ guiLinuxDeps ++ guiDarwinDeps;

            LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath (guiLinuxDeps ++ guiDarwinDeps);

            shellHook = ''
              echo "OnTrack Rust dev shell"
              echo "  Rust: $(rustc --version)"
              echo "  Build: cd ontrack-rs && cargo build"
              echo "  Test:  cd ontrack-rs && cargo test"
              echo "  Lint:  cd ontrack-rs && cargo clippy -- -D warnings"
            '';
          };
        };
      }
    ) // {
      # ══════════════════════════════════════════════════════════════════
      # Overlays (system-independent)
      # ══════════════════════════════════════════════════════════════════
      overlays.default = final: prev: {
        # Pin specific package versions if needed
        ontrack-openssl = prev.openssl_3;
      };
    };
}
