{
  pkgs,
  lib,
  impala,
  artic,
  ...
}:
let
  stdenv = pkgs.stdenv;
  build_type = "Debug";

  enable_jit = "true";
  enable_debug_output = "true";

  artic_cmake_path = "${artic}/share/anydsl/cmake";
  impala_cmake_path = "${impala}/share/anydsl/cmake";
in stdenv.mkDerivation rec {
  pname = "runtime";
  version = "git";

  src = pkgs.fetchFromGitHub {
    owner = "AnyDSL";
    repo = "runtime";
    rev = "e31cec49ffe64342a1252f62942d882c198d7a3b";
    sha256 = "baba23AxeHd4iUQrMUPrgjOn0AaUQ9cg9ADNWQNBPQI=";
  };

  nativeBuildInputs = [ pkgs.cmake ];

  buildInputs = [ thorin ];

  postBuild = "rm -fR $out";

  cmakeFlags = with stdenv; [
    "-DCMAKE_BUILD_TYPE:STRING=${build_type}"
    "-DRUNTIME_JIT:BOOL=${enable_jit}"
    "-DDEBUG_OUTPUT:BOOL=${enable_debug_output}"
    "-DArtic_DIR:PATH=${artic_cmake_path}"
    "-DImpala_DIR:PATH=${impala_cmake_path}"
  ];

  meta = {
    description = "AnyDSL runtime";
    homepage    = "https://anydsl.github.io/";
  };
}
