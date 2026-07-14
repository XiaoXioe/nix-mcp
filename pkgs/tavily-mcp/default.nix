{ pkgs, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "tavily-mcp";
  version = "0.2.20";

  src =
    pkgs.runCommand "tavily-mcp-src"
      {
        nativeBuildInputs = [
          pkgs.nodejs
          pkgs.cacert
        ];
        outputHashAlgo = "sha256";
        outputHashMode = "recursive";
        outputHash = "sha256-TQfsmW/8lqFFhuY0sYSGxLXCNXm0AoJ9V5NF6vUakng=";
      }
      ''
        export HOME=$TMPDIR
        mkdir -p $out/lib
        cd $out/lib
        npm install --no-audit --no-fund --production tavily-mcp@${version}
      '';

  nativeBuildInputs = [ pkgs.makeWrapper ];

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin $out/lib
    cp -r $src/lib/node_modules $out/lib/node_modules
    chmod -R +w $out/lib/node_modules
    rm -f $out/lib/node_modules/.package-lock.json
    makeWrapper ${pkgs.nodejs}/bin/node $out/bin/tavily-mcp \
      --add-flags "$out/lib/node_modules/tavily-mcp/build/index.js"
  '';
}
