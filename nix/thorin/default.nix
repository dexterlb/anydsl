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

  propagatedBuildInputs = [ llvm half ];

  postBuild = "rm -fR $out";

  cmakeFlags = with stdenv; [
    "-DCMAKE_BUILD_TYPE:STRING=${build_type}"
    "-DLLVM_DIR:PATH=${llvm_cmake_path}"
    "-DTHORIN_PROFILE:BOOL=${enable_profiling}"
    "-DHalf_DIR:PATH=${half_include_path}"
  ];

  installPhase = ''
    cp -raf ./{lib,share,include}/ $out/
  '';

  meta = {
    description = "Thorin";
    homepage    = "https://anydsl.github.io/";
  };
}
