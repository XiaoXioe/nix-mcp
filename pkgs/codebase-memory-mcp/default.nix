{ pkgs, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "codebase-memory-mcp";
  version = "0.8.1";

  src = pkgs.fetchurl {
    url = "https://github.com/DeusData/codebase-memory-mcp/releases/download/v${version}/codebase-memory-mcp-linux-amd64.tar.gz";
    sha256 = "sha256-29O5Lqhw7yQLYwWfJr2hUBX3bvmXiTG+vDoPnQlHCXM=";
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
