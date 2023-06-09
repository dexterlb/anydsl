{
  pkgs,
  lib,
  impala,
  runtime,
  thorin,
  ...
}:
let
  stdenv = pkgs.stdenv;
  build_type = "Debug";

  runtime_cmake_path = "${runtime}/share/anydsl/cmake";
  runtime_include_path = "${runtime}/include";
  runtime_module_path = "${runtime}/share/anydsl/cmake/modules";

  impala_module_path = "${impala}/share/anydsl/cmake/modules";

  thorin_cmake_path = "${thorin}/share/anydsl/cmake";
  thorin_include_path = "${thorin}/include";
  thorin_module_path = "${thorin}/share/anydsl/cmake/modules";

  install_script = ./../install_anydsl_project.sh;
in stdenv.mkDerivation rec {
  pname = "rodent";
  version = "git";

  src = pkgs.fetchFromGitHub {
    owner = "AnyDSL";
    repo = "rodent";
    rev = "9aa45b24b72f24fa650a505f729e41e325b8b9b9";
    sha256 = "jAT9zvYkn9ssp7H+02Ec5fFhfyL83XOeWzKhn4omnOQ=";
  };

  nativeBuildInputs = [ pkgs.patchelf pkgs.cmake pkgs.python3 ];

  buildInputs = [ impala thorin runtime ];

  propagatedBuildInputs = [ ];

  postBuild = "rm -fR $out";

  dontStrip = true;

  installPhase = ''
    bash "${install_script}" "$out"
  '';

  cmakeFlags = with stdenv; [
    "-DCMAKE_BUILD_TYPE:STRING=${build_type}"
    "-DThorin_DIR:PATH=${thorin_cmake_path}"
    "-DThorin_INCLUDE_DIR:PATH=${thorin_include_path}"
    "-DAnyDSL_runtime_DIR:PATH=${runtime_cmake_path}"
    "-DAnyDSL_runtime_INCLUDE_DIR:PATH=${runtime_include_path}"

    "-DCMAKE_MODULE_PATH=${thorin_module_path};${impala_module_path};${runtime_module_path}"
  ];

  meta = {
    description = "Rodent";
    homepage    = "https://anydsl.github.io/";
  };
}
