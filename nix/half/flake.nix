{
  description = "patched LLVM with RV";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    flake-utils.url = github:numtide/flake-utils;
    nix-std.url = github:chessai/nix-std;
  };

  outputs = { self, nixpkgs, flake-utils, nix-std }:
    with flake-utils.lib;
    eachSystem allSystems (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        stdenv = pkgs.stdenv;
        lib = nixpkgs.lib;
      in
      rec {
        packages.half = pkgs.stdenvNoCC.mkDerivation rec {
          name = "half";

          src = pkgs.fetchsvn {
            url = "svn://svn.code.sf.net/p/half/code/trunk";
            rev = "419";
            # sha256 = "vffu4HilvYwtzwgq+NlS26m65DGbp6OSSne2aje1yJE=";
          };

          buildInputs = [ pkgs.coreutils pkgs.bash ];
          phases = [ "unpackPhase" "buildPhase" "installPhase" ];
          buildPhase = ''
          '';
          installPhase = ''
            mkdir -p $out
            cp -rav * $out/
          '';
        };
        packages.default = packages.half;
      }
    );
}
