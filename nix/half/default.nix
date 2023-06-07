{
  pkgs,
  nixpkgs,
}:
let
  stdenv = pkgs.stdenv;
  lib = nixpkgs.lib;
in pkgs.stdenvNoCC.mkDerivation rec {
  name = "half";

  src = pkgs.fetchsvn {
    url = "svn://svn.code.sf.net/p/half/code/trunk";
    rev = "419";
    sha256 = "3bcofNbADRHoK3zgn/b/OFGwrRsqgQaKWldBzaBJOOs=";
  };

  buildInputs = [ pkgs.coreutils pkgs.bash ];
  phases = [ "unpackPhase" "buildPhase" "installPhase" ];
  buildPhase = ''
  '';
  installPhase = ''
    mkdir -p $out
    cp -rav * $out/
  '';
}
