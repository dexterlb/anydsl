{
  pkgs,
  lib,
  impala,
  artic,
  thorin,
  ...
}:
let
  stdenv = pkgs.stdenv;
  build_type = "Debug";

  enable_jit = "true";
  enable_debug_output = "true";

  artic_cmake_path = "${artic}/share/anydsl/cmake";
  artic_module_path = "${artic}/share/anydsl/cmake/modules";
  impala_cmake_path = "${impala}/share/anydsl/cmake";
  impala_module_path = "${impala}/share/anydsl/cmake/modules";
  thorin_cmake_path = "${thorin}/share/anydsl/cmake";
  thorin_module_path = "${thorin}/share/anydsl/cmake/modules";

  install_script = ./../install_anydsl_project.sh;
in stdenv.mkDerivation rec {
  pname = "runtime";
  version = "git";

  src = pkgs.fetchFromGitHub {
    owner = "AnyDSL";
    repo = "runtime";
    rev = "e31cec49ffe64342a1252f62942d882c198d7a3b";
    sha256 = "Mnnsh0qqJlu4yrVEq1TTvgMddrcs2WSj+t85V2RU0/A=";
  };

  nativeBuildInputs = [ pkgs.cmake ];

  buildInputs = [ thorin artic impala pkgs.python3 ];

  postBuild = "rm -fR $out";

  installPhase = ''
    bash "${install_script}" "$out"
  '';

  cmakeFlags = with stdenv; [
    "-DCMAKE_BUILD_TYPE:STRING=${build_type}"
    "-DRUNTIME_JIT:BOOL=${enable_jit}"
    "-DDEBUG_OUTPUT:BOOL=${enable_debug_output}"
    "-DArtic_DIR:PATH=${artic_cmake_path}"
    "-DImpala_DIR:PATH=${impala_cmake_path}"
    "-DThorin_DIR:PATH=${thorin_cmake_path}"

    "-DCMAKE_MODULE_PATH=${thorin_module_path};${impala_module_path};${artic_module_path}"
  ];

  meta = {
    description = "AnyDSL runtime";
    homepage    = "https://anydsl.github.io/";
  };
}