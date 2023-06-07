{
  description = "AnyDSL";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    flake-utils.url = github:numtide/flake-utils;
  };

  outputs = { self, nixpkgs, flake-utils }:
    with flake-utils.lib;
    eachSystem allSystems (system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in rec {
        packages.llvm = (import ./llvm) { nixpkgs = nixpkgs; pkgs = pkgs; };
        packages.half = (import ./half) { nixpkgs = nixpkgs; pkgs = pkgs; };
        packages.thorin = (import ./thorin) {
          nixpkgs = nixpkgs; pkgs = pkgs;
          half = packages.half;
          llvm = packages.llvm;
        };
        packages.default = packages.thorin;
      }
  );
}
