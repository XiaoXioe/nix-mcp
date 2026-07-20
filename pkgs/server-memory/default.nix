{ pkgs, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "server-memory";
  version = "2026.7.4";

  src =
    pkgs.runCommand "server-memory-src"
      {
        nativeBuildInputs = [
          pkgs.nodejs
          pkgs.cacert
        ];
        outputHashAlgo = "sha256";
        outputHashMode = "recursive";
        outputHash = "sha256-iZQjKKDlCzmaIvPloFV7YtzZuLu0QxzkilZMkx+3K+E=";
      }
      ''
        export HOME=$TMPDIR
        mkdir -p $out/lib/server-memory
        cd $out/lib/server-memory
        npm install --no-audit --no-fund --production @modelcontextprotocol/server-memory@${version}
      '';

  nativeBuildInputs = [ pkgs.makeWrapper ];

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin $out/lib/server-memory
    ln -s $src/lib/server-memory/node_modules $out/lib/server-memory/node_modules
    makeWrapper ${pkgs.nodejs}/bin/node $out/bin/mcp-server-memory \
      --add-flags "$out/lib/server-memory/node_modules/@modelcontextprotocol/server-memory/dist/index.js"
  '';
}
