{
  description = "Ontrack PyO3/maturin crate";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
    python = pkgs.python312;
    pythonPackages = python.pkgs;
  in {
    apps.${system}.default = {
      program = "${self.packages.${system}.default}/bin/ontrack";
      type = "app";
    };

    devShells.${system}.default = pkgs.mkShell {
      packages = [
        pkgs.cargo
        pkgs.maturin
        pkgs.rustc
        python
        pythonPackages.pip
      ];
      shellHook = ''
        echo "Dev shell for ontrack (PyO3/maturin)"
      '';
    };

    packages.${system}.default = pythonPackages.buildPythonPackage rec {
      cargoDeps = pkgs.rustPlatform.fetchCargoTarball {
        name = "${pname}-${version}-crate-deps";
        src = ./.;
      };
      format = "pyproject";
      nativeBuildInputs = [
        pkgs.cargo
        pkgs.maturin
        pkgs.openssl
        pkgs.pkg-config
        pkgs.rustc
      ];
      pname = "ontrack";
      propagatedBuildInputs = [ ];
      src = ./.;
      version = "0.1.0";
    };
  };
}
