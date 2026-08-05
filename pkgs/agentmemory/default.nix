{
  lib,
  stdenv,
  runCommand,
  nodejs,
  cacert,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "agentmemory";
  version = "0.9.28";

  src =
    runCommand "agentmemory-src"
      {
        nativeBuildInputs = [
          nodejs
          cacert
        ];
        outputHashAlgo = "sha256";
        outputHashMode = "recursive";
        outputHash = "sha256-Ox3tMrhrhRKty+7d4ZT5u7MsQhN+DgY9k2mU01acjqI=";
      }
      ''
        export HOME=$TMPDIR
        mkdir -p $out/lib/agentmemory
        cd $out/lib/agentmemory
        npm install --no-audit --no-fund --production @agentmemory/agentmemory@${finalAttrs.version} @agentmemory/mcp@${finalAttrs.version}
      '';

  nativeBuildInputs = [ makeWrapper ];

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin $out/lib/agentmemory
    ln -s $src/lib/agentmemory/node_modules $out/lib/agentmemory/node_modules
    makeWrapper ${nodejs}/bin/node $out/bin/agentmemory \
      --add-flags "$out/lib/agentmemory/node_modules/@agentmemory/agentmemory/dist/cli.mjs"
    makeWrapper ${nodejs}/bin/node $out/bin/agentmemory-mcp \
      --add-flags "$out/lib/agentmemory/node_modules/@agentmemory/mcp/bin.mjs"
  '';

  meta = {
    description = "Standalone MCP server for agentmemory";
    homepage = "https://github.com/rohitg00/agentmemory";
    license = lib.licenses.mit;
    mainProgram = "agentmemory-mcp";
    platforms = lib.platforms.all;
  };
})
