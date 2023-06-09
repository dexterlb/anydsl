{
  pkgs,
  lib,
  llvm,
  half,
  ...
}:
let
  stdenv = pkgs.stdenv;
  build_type = "Debug";
  enable_profiling = "false";

  llvm_cmake_path = "${llvm}/lib/cmake/llvm";
  half_include_path = "${half}/include";
in stdenv.mkDerivation rec {
  pname = "thorin";
  version = "git";

  src = pkgs.fetchFromGitHub {
    owner = "AnyDSL";
    repo = "thorin";
    rev = "cd1c6c5ff138204b77971d2b23cd9958e30a91b0";
    sha256 = "HY0b23AxeHd4iUQrMUPrgjOn0AaUQ9cg9ADNWQNBPQI=";
  };


  nativeBuildInputs = [ pkgs.cmake ];

  propagatedBuildInputs = [ llvm half pkgs.libxml2 ];

  buildInputs = [ pkgs.libffi ];

  postBuild = "rm -fR $out";

  cmakeFlags = with stdenv; [
    "-DCMAKE_BUILD_TYPE:STRING=${build_type}"
    "-DLLVM_DIR:PATH=${llvm_cmake_path}"
    "-DTHORIN_PROFILE:BOOL=${enable_profiling}"
    "-DHalf_DIR:PATH=${half_include_path}"
  ];

  installPhase = ''
    mkdir -p $out
    build_dir="''$(pwd)"
    source_dir="''$(readlink -f ''$build_dir/..)"

    # So, thorin doesn't define a CMake "Install" target,
    # and since the developers haven't bothered to create one,
    # I'm guessing there's some roadblock to this.
    # I will look into it in the future, but for now, I'm lazy.

    # Thus, I'm "installing" the artefacts in the old-fashioned way:

    mkdir -p $out/include
    cp -raf $src/src/thorin $out/include/
    chmod -R u+w $out/include
    find $out/include -type f -not -iname '*.h' -delete
    find $out/include -type d -empty -delete
    cp -raf ./{lib,share,include}/ $out/
    cp -raf $src/cmake/modules $out/share/anydsl/cmake/

    # However, the built artefacts contain references to the build dir.
    # So I present this abomination for removing them:
    sed -r -e ":''$build_dir:d" -i $out/share/anydsl/cmake/thorin-config.cmake
    sed -r -e "s:''$build_dir/(lib|share|include):$out/\1:g" -e "s:;''$source_dir/src;:;:g" -i $out/share/anydsl/cmake/thorin-exports.cmake

    # This is a massive hack. Instead of doing this, we should coerce cmake
    # to output a proper tree that doesn't reference the build dir. TODO.
  '';

  dontStrip = (build_type != "Release");

  meta = {
    description = "Thorin";
    homepage    = "https://anydsl.github.io/";
  };
}
