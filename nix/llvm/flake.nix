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
          stdenv.mkDerivation rec {
            pname = "llvm";
            version = "14-git";

            llvmRepoSrc = pkgs.fetchFromGitHub {
              owner = "llvm";
              repo = "llvm-project";
              rev = "f28c006a5895fc0e329fe15fead81e37457cb1d1";
              sha256 = "vffu4HilvYwtzwgq+NlS26m65DGbp6OSSne2aje1yJE=";
            };

            src = pkgs.runCommand "${pname}-src-${version}" {} (''
              mkdir -p "$out"
              cp -r ${llvmRepoSrc}/cmake "$out"
              cp -r ${llvmRepoSrc}/llvm "$out"
              cp -r ${llvmRepoSrc}/third-party "$out"
            '');

            sourceRoot = "${src.name}/llvm";

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
