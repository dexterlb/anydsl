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

  nativeBuildInputs = [ pkgs.patchelf pkgs.cmake ];

  buildInputs = [ ];

  propagatedBuildInputs = [ thorin ];

  postBuild = "rm -fR $out";

  dontStrip = true;

  installPhase = ''
    build_dir=''$(pwd)

    mkdir -p $out

    cp -raf ./{bin,lib,share}/ $out/

    function fix_rpath {
      old_rpath="''$(patchelf --print-rpath "''$1")"
      rpath="''$(echo "''$old_rpath" | sed -r "s|''$build_dir|$out|g")"
      echo "changing RPATH of ''$1 from ''$old_rpath to ''$rpath" >&2

      patchelf --set-rpath "''$rpath" "''$1"
    }

    for binary in "''$out/bin"/*; do
      fix_rpath "''$binary"
    done
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
