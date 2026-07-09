{ pkgs, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "codebase-memory-mcp";
  version = "0.9.0";

  src = pkgs.fetchurl {
    url = "https://github.com/DeusData/codebase-memory-mcp/releases/download/v${version}/codebase-memory-mcp-linux-amd64.tar.gz";
    sha256 = "sha256-4oMqjSB8Jr6qMO+mIi7Uo3yz9SbKS+4GC/vzNu1vxnk=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [
    pkgs.autoPatchelfHook
    pkgs.prelink
  ];

  buildInputs = [
    pkgs.stdenv.cc.cc.lib
    pkgs.zlib
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp codebase-memory-mcp $out/bin/
    chmod +x $out/bin/codebase-memory-mcp
    execstack -c $out/bin/codebase-memory-mcp
  '';
}
