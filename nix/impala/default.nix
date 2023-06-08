{
  pkgs,
  lib,
  thorin,
  ...
}:
let
  stdenv = pkgs.stdenv;
  build_type = "Debug";

  thorin_cmake_path = "${thorin}/share/anydsl/cmake";
  thorin_include_path = "${thorin}/include";
  thorin_module_path = "${thorin}/share/anydsl/cmake/modules";
in stdenv.mkDerivation rec {
  pname = "impala";
  version = "git";

  src = pkgs.fetchFromGitHub {
    owner = "AnyDSL";
    repo = "impala";
    rev = "c58a0ae142146b3fdf7dc5aebd813f8d56a1b010";
    sha256 = "HHy72vBkxM8BVi3RlObWH3mh0/tgE1aAy2J/KQlMldQ=";
  };

  nativeBuildInputs = [ pkgs.cmake ];

  buildInputs = [ thorin ];

  postBuild = "rm -fR $out";

  installPhase = ''
    mkdir -p $out
    cp -raf ./{bin,lib,share,include}/ $out/
  '';

  cmakeFlags = with stdenv; [
    "-DCMAKE_BUILD_TYPE:STRING=${build_type}"
    "-DThorin_DIR:PATH=${thorin_cmake_path}"
    "-DThorin_INCLUDE_DIR:PATH=${thorin_include_path}"

    "-DCMAKE_MODULE_PATH=${thorin_module_path}"
  ];

  meta = {
    description = "Impala";
    homepage    = "https://anydsl.github.io/";
  };
}
