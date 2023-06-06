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
        packages.llvm =
          stdenv.mkDerivation {
            pname = "llvm";
            version = "3.6-mono-2017-02-15";

            src = pkgs.fetchFromGitHub {
              owner = "mono";
              repo = "llvm";
              rev = "dbb6fdffdeb780d11851a6be77c209bd7ada4bd3";
              sha256 = "07wd1cs3fdvzb1lv41b655z5zk34f47j8fgd9ljjimi5j9pj71f7";
            };

            nativeBuildInputs = [ pkgs.cmake ];
            buildInputs = [
              pkgs.python3 pkgs.perl pkgs.groff pkgs.libxml2 pkgs.libffi
            ] ++ lib.optional stdenv.isLinux pkgs.valgrind;

            propagatedBuildInputs = [ pkgs.ncurses pkgs.zlib ];

            # hacky fix: created binaries need to be run before installation
            preBuild = ''
              mkdir -p $out/
              ln -sv $PWD/lib $out
            '';
            postBuild = "rm -fR $out";

            cmakeFlags = with stdenv; [
              "-DLLVM_ENABLE_FFI=ON"
              "-DLLVM_BINUTILS_INCDIR=${pkgs.libbfd.dev}/include"
            ] ++ lib.optional (!isDarwin) "-DBUILD_SHARED_LIBS=ON";

            meta = {
              description = "Patched LLVM with RV";
              homepage    = "https://anydsl.github.io/";
              license     = lib.licenses.bsd3;
              maintainers = with lib.maintainers; [ thoughtpolice ];
              platforms   = lib.platforms.all;
            };
          };
        packages.default = packages.llvm;
      }
    );
}
