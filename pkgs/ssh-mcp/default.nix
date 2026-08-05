{
  lib,
  stdenv,
  runCommand,
  nodejs,
  cacert,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ssh-mcp";
  version = "1.5.0";

  src =
    runCommand "ssh-mcp-src"
      {
        nativeBuildInputs = [
          nodejs
          cacert
        ];
        outputHashAlgo = "sha256";
        outputHashMode = "recursive";
        outputHash = "sha256-MU6IiT+fDbx1smOBaLiAf4wEuh6c19coH5IPDK5zQ+Y=";
      }
      ''
        export HOME=$TMPDIR
        mkdir -p $out/lib
        cd $out/lib
        npm install --no-audit --no-fund --production ssh-mcp@${finalAttrs.version}
      '';

  nativeBuildInputs = [ makeWrapper ];

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin $out/lib
    ln -s $src/lib/node_modules $out/lib/node_modules
    makeWrapper ${nodejs}/bin/node $out/bin/ssh-mcp \
      --add-flags "$out/lib/node_modules/ssh-mcp/build/index.js"
  '';

  meta = {
    description = "MCP server exposing SSH control for Linux and Windows systems";
    homepage = "https://github.com/tufantunc/ssh-mcp";
    license = lib.licenses.mit;
    mainProgram = "ssh-mcp";
    platforms = lib.platforms.all;
  };
})
