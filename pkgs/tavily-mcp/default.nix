{ pkgs, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "tavily-mcp";
  version = "0.2.21";

  src =
    pkgs.runCommand "tavily-mcp-src"
      {
        nativeBuildInputs = [
          pkgs.nodejs
          pkgs.cacert
        ];
        outputHashAlgo = "sha256";
        outputHashMode = "recursive";
        outputHash = "sha256-2dD0N7M+QJz1MPfj5jlNRewkI42y9zXasS/37P6Cepo="; # Dummy hash
      }
      ''
        export HOME=$TMPDIR
        mkdir -p $out/lib/tavily-mcp
        cd $out/lib/tavily-mcp
        npm install --no-audit --no-fund --production tavily-mcp@${version}
      '';

  nativeBuildInputs = [ pkgs.makeWrapper ];

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin $out/lib/tavily-mcp
    ln -s $src/lib/tavily-mcp/node_modules $out/lib/tavily-mcp/node_modules
    makeWrapper ${pkgs.nodejs}/bin/node $out/bin/tavily-mcp \
      --add-flags "$out/lib/tavily-mcp/node_modules/tavily-mcp/build/index.js"
  '';
}
