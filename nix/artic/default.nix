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
  pname = "artic";
  version = "git";

  src = pkgs.fetchFromGitHub {
    owner = "AnyDSL";
    repo = "artic";
    rev = "bb9f15faa788671647e1c98612cacc876c834021";
    sha256 = "kMy8oFg1R0t/ldKOI7JY2PxA/OzRT7nSoFAhweMkSco=";
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
    description = "Artic";
    homepage    = "https://anydsl.github.io/";
  };
}
