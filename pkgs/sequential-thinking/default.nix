{ pkgs, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "sequential-thinking";
  version = "2026.7.4";

  src =
    pkgs.runCommand "sequential-thinking-src"
      {
        nativeBuildInputs = [
          pkgs.nodejs
          pkgs.cacert
        ];
        outputHashAlgo = "sha256";
        outputHashMode = "recursive";
        outputHash = "sha256-+Xu+QlRBMl6sgYDZC6LReb0TowXP7iMnrxJCeuxPsGs=";
      }
      ''
        export HOME=$TMPDIR
        mkdir -p $out/lib/sequential-thinking
        cd $out/lib/sequential-thinking
        npm install --no-audit --no-fund --production @modelcontextprotocol/server-sequential-thinking@${version}
      '';

  nativeBuildInputs = [ pkgs.makeWrapper ];

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin $out/lib/sequential-thinking
    ln -s $src/lib/sequential-thinking/node_modules $out/lib/sequential-thinking/node_modules
    makeWrapper ${pkgs.nodejs}/bin/node $out/bin/mcp-server-sequential-thinking \
      --add-flags "$out/lib/sequential-thinking/node_modules/@modelcontextprotocol/server-sequential-thinking/dist/index.js"
  '';
}
