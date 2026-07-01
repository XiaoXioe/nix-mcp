{ pkgs, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "ssh-mcp";
  version = "1.5.0";

  src =
    pkgs.runCommand "ssh-mcp-src"
      {
        nativeBuildInputs = [
          pkgs.nodejs
          pkgs.cacert
        ];
        outputHashAlgo = "sha256";
        outputHashMode = "recursive";
        outputHash = "sha256-MU6IiT+fDbx1smOBaLiAf4wEuh6c19coH5IPDK5zQ+Y=";
      }
      ''
        export HOME=$TMPDIR
        mkdir -p $out/lib
        cd $out/lib
        npm install --no-audit --no-fund --production ssh-mcp@${version}
      '';

  nativeBuildInputs = [ pkgs.makeWrapper ];

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin $out/lib
    ln -s $src/lib/node_modules $out/lib/node_modules
    makeWrapper ${pkgs.nodejs}/bin/node $out/bin/ssh-mcp \
      --add-flags "$out/lib/node_modules/ssh-mcp/build/index.js"
  '';
}
