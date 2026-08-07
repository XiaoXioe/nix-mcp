{
  lib,
  stdenv,
  fetchFromGitHub,
  runCommand,
  nodejs,
  cacert,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tencentdb-agent-memory";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "TencentCloud";
    repo = "TencentDB-Agent-Memory";
    rev = "v${finalAttrs.version}";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  deps =
    runCommand "${finalAttrs.pname}-deps"
      {
        nativeBuildInputs = [
          nodejs
          cacert
        ];
        outputHashAlgo = "sha256";
        outputHashMode = "recursive";
        outputHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
      }
      ''
        export HOME=$TMPDIR
        mkdir -p $out/lib/tencentdb-agent-memory
        cd ${finalAttrs.src}/MemoryCore
        npm install --no-audit --no-fund --production
        cp -r node_modules $out/lib/tencentdb-agent-memory/
      '';

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin $out/lib/tencentdb-agent-memory
    cp -r $src/MemoryCore/* $out/lib/tencentdb-agent-memory/
    ln -s $deps/lib/tencentdb-agent-memory/node_modules $out/lib/tencentdb-agent-memory/node_modules

    makeWrapper ${nodejs}/bin/node $out/bin/tencentdb-agent-memory \
      --add-flags "$out/lib/tencentdb-agent-memory/src/gateway/server.ts"
  '';

  meta = {
    description = "Team-level memory hub and MCP server for AI Agents by Tencent Cloud";
    homepage = "https://github.com/TencentCloud/TencentDB-Agent-Memory";
    license = lib.licenses.mit;
    mainProgram = "tencentdb-agent-memory";
    platforms = lib.platforms.all;
  };
})
