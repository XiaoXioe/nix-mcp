{ pkgs, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "agentmemory";
  version = "0.9.28";

  src =
    pkgs.runCommand "agentmemory-src"
      {
        nativeBuildInputs = [
          pkgs.nodejs
          pkgs.cacert
        ];
        outputHashAlgo = "sha256";
        outputHashMode = "recursive";
        outputHash = "sha256-F7y9Xm9sO90smuJr0I7p8/vS3dxnX4VcMzeXjULHOkg=";
      }
      ''
        export HOME=$TMPDIR
        mkdir -p $out/lib/agentmemory
        cd $out/lib/agentmemory
        npm install --no-audit --no-fund --production @agentmemory/agentmemory@${version} @agentmemory/mcp@${version}
      '';

  nativeBuildInputs = [ pkgs.makeWrapper ];

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin $out/lib/agentmemory
    ln -s $src/lib/agentmemory/node_modules $out/lib/agentmemory/node_modules
    makeWrapper ${pkgs.nodejs}/bin/node $out/bin/agentmemory \
      --add-flags "$out/lib/agentmemory/node_modules/@agentmemory/agentmemory/dist/cli.mjs"
    makeWrapper ${pkgs.nodejs}/bin/node $out/bin/agentmemory-mcp \
      --add-flags "$out/lib/agentmemory/node_modules/@agentmemory/mcp/bin.mjs"
  '';
}
