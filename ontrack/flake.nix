# This flake is superseded by the unified root flake at ../flake.nix
# Use `nix build .#ontrack-py` from the repository root instead.
#
# To enter a Python dev shell:   nix develop .#python   (from repo root)
# To build the Python package:   nix build .#ontrack-py (from repo root)
# To run all checks:             nix flake check        (from repo root)
{
  description = "DEPRECATED — see root flake.nix for unified OnTrack builds";

  inputs.root.url = "path:..";

  outputs = { root, ... }: root;
}
