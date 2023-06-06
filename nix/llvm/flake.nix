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
        llvm_targets = "AArch64;AMDGPU;ARM;NVPTX;X86";
        build_type = "Debug";
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
              cp -r ${llvmRepoSrc}/lld "$out"
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

              "-DLLVM_BUILD_LLVM_DYLIB:BOOL=ON"
              "-DLLVM_LINK_LLVM_DYLIB:BOOL=ON"
              "-DCMAKE_BUILD_TYPE:STRING=${build_type}"

              # "-DLLVM_EXTERNAL_PROJECTS:STRING=rv"
              # "-DLLVM_EXTERNAL_RV_SOURCE_DIR:PATH=${out}/llvm-project/rv"

              "-DLLVM_ENABLE_RTTI:BOOL=ON"
              # "-DLLVM_ENABLE_PROJECTS:STRING=clang;lld"
              "-DLLVM_ENABLE_PROJECTS:STRING=lld"
              "-DLLVM_ENABLE_BINDINGS:BOOL=OFF"
              "-DLLVM_INCLUDE_TESTS:BOOL=ON"
              "-DLLVM_TARGETS_TO_BUILD:STRING=${llvm_targets}"
            ] ++ lib.optional (isDarwin) "-RV_REBUILD_GENBC:BOOL=ON";

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
