{
  description = "patched LLVM with RV";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    flake-utils.url = github:numtide/flake-utils;
    nix-std.url = github:chessai/nix-std;

    llvm.url = "../llvm";
    half.url = "../half";
  };

  outputs = { self, nixpkgs, flake-utils, nix-std, llvm, half }:
    with flake-utils.lib;
    eachSystem allSystems (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        stdenv = pkgs.stdenv;
        lib = nixpkgs.lib;
        build_type = "Debug";
        enable_profiling = false;

        llvm_pkg = llvm.packages.${system}.llvm;
        half_pkg = half.packages.${system}.half;

        llvm_cmake_path = "${llvm_pkg}/lib/cmake/llvm";
        half_include_path = "${half_pkg}/include";
      in
      rec {
        packages.thorin =
          stdenv.mkDerivation rec {
            pname = "thorin";
            version = "git";

            src = pkgs.fetchFromGitHub {
              owner = "AnyDSL";
              repo = "thorin";
              rev = "cd1c6c5ff138204b77971d2b23cd9958e30a91b0";
              # sha256 = "vffu4HilvYwtzwgq+NlS26m65DGbp6OSSne2aje1yJE=";
            };

            nativeBuildInputs = [ pkgs.cmake llvm.packages.${system}.llvm ];

            buildInputs = [
            ];

            propagatedBuildInputs = [ pkgs.ncurses pkgs.zlib ];

            postBuild = "rm -fR $out";

            cmakeFlags = with stdenv; [
              "-DCMAKE_BUILD_TYPE:STRING=${build_type}"
              "-DLLVM_DIR:PATH=${llvm_cmake_path}"
              "-DTHORIN_PROFILE:BOOL=${enable_profiling}"
              "-DHalf_DIR:PATH=${half_include_path}"
            ];

            meta = {
              description = "Thorin";
              homepage    = "https://anydsl.github.io/";
              license     = lib.licenses.bsd3;
              maintainers = with lib.maintainers; [ thoughtpolice ];
              platforms   = lib.platforms.all;
            };
          };
        packages.default = packages.thorin;
      }
    );
}
