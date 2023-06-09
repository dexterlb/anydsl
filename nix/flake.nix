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
        lib = nixpkgs.lib;
      in rec {
        packages.llvm = (import ./llvm) { inherit pkgs lib; };
        packages.half = (import ./half) { inherit pkgs lib; };
        packages.thorin = (import ./thorin) {
          inherit pkgs lib;
          half = packages.half;
          llvm = packages.llvm;
        };
        packages.artic = (import ./artic) {
          inherit pkgs lib;
          thorin = packages.thorin;
        };
        packages.impala = (import ./impala) {
          inherit pkgs lib;
          thorin = packages.thorin;
        };
        packages.runtime = (import ./runtime) {
          inherit pkgs lib;
          impala = packages.impala;
          artic = packages.artic;
          thorin = packages.thorin;
        };
        packages.rodent = (import ./rodent) {
          inherit pkgs lib;
          impala = packages.impala;
          thorin = packages.thorin;
          runtime = packages.runtime;
        };

        packages.default = packages.impala;

        devShell = pkgs.mkShell {
          packages = [
            packages.llvm
            packages.thorin
            packages.impala
            packages.artic
            packages.runtime
          ];
        };
      }
  );
}
