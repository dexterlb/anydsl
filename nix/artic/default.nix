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
in stdenv.mkDerivation rec {
  pname = "artic";
  version = "git";

  src = pkgs.fetchFromGitHub {
    owner = "AnyDSL";
    repo = "artic";
    rev = "bb9f15faa788671647e1c98612cacc876c834021";
    sha256 = "kMy8oFg1R0t/ldKOI7JY2PxA/OzRT7nSoFAhweMkSco=";
  };

  nativeBuildInputs = [ pkgs.cmake ];

  buildInputs = [ thorin ];

  postBuild = "rm -fR $out";

  cmakeFlags = with stdenv; [
    "-DCMAKE_BUILD_TYPE:STRING=${build_type}"
    "-DThorin_DIR:PATH=${thorin_cmake_path}"
  ];

  meta = {
    description = "Artic";
    homepage    = "https://anydsl.github.io/";
  };
}
