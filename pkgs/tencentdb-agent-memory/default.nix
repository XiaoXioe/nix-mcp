{
  lib,
  stdenv,
  fetchFromGitHub,
  runCommand,
  nodejs,
  cacert,
  makeWrapper,
  python3,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tencentdb-agent-memory";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "TencentCloud";
    repo = "TencentDB-Agent-Memory";
    rev = "v${finalAttrs.version}";
    hash = "sha256-G8BSb+RjY3MxNSEQ+z54QLEJTXYxwUP9IqD4G1TKUKs=";
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
        mkdir -p $TMPDIR/build-core $TMPDIR/build-knowledge $out/lib/tencentdb-agent-memory
        
        cp -r ${finalAttrs.src}/MemoryCore/* $TMPDIR/build-core/
        chmod -R +w $TMPDIR/build-core
        cd $TMPDIR/build-core
        npm install --ignore-scripts --no-audit --no-fund --production
        cp -r node_modules $out/lib/tencentdb-agent-memory/

        if [ -d "${finalAttrs.src}/MemoryKnowledge" ]; then
          cp -r ${finalAttrs.src}/MemoryKnowledge/* $TMPDIR/build-knowledge/
          chmod -R +w $TMPDIR/build-knowledge
          cd $TMPDIR/build-knowledge
          npm install --ignore-scripts --no-audit --no-fund --production
          mkdir -p $out/lib/tencentdb-agent-memory/MemoryKnowledge
          cp -r node_modules $out/lib/tencentdb-agent-memory/MemoryKnowledge/
        fi
      '';

  nativeBuildInputs = [
    makeWrapper
    python3
    pkg-config
  ];

  installPhase = ''
    mkdir -p $out/bin $out/lib/tencentdb-agent-memory
    cp -r $src/MemoryCore/* $out/lib/tencentdb-agent-memory/
    if [ -d "$src/MemoryKnowledge" ]; then
      mkdir -p $out/lib/tencentdb-agent-memory/MemoryKnowledge
      cp -r $src/MemoryKnowledge/* $out/lib/tencentdb-agent-memory/MemoryKnowledge/
      if [ -d "$deps/lib/tencentdb-agent-memory/MemoryKnowledge/node_modules" ]; then
        ln -s $deps/lib/tencentdb-agent-memory/MemoryKnowledge/node_modules $out/lib/tencentdb-agent-memory/MemoryKnowledge/node_modules
      fi
    fi
    ln -s $deps/lib/tencentdb-agent-memory/node_modules $out/lib/tencentdb-agent-memory/node_modules

    makeWrapper ${nodejs}/bin/node $out/bin/tencentdb-agent-memory \
      --set-default LOG_PATH "\$HOME/.agents/tencent_memory/logs" \
      --set-default TDAI_API_TRACE_ENABLED "false" \
      --add-flags "$out/lib/tencentdb-agent-memory/node_modules/tsx/dist/cli.mjs $out/lib/tencentdb-agent-memory/src/gateway/server.ts"

    if [ -f "$src/MemoryKnowledge/src/mcp/server.ts" ]; then
      makeWrapper ${nodejs}/bin/node $out/bin/tencentdb-agent-memory-mcp \
        --set-default LOG_PATH "\$HOME/.agents/tencent_memory/logs" \
        --set-default TDAI_API_TRACE_ENABLED "false" \
        --add-flags "$out/lib/tencentdb-agent-memory/MemoryKnowledge/node_modules/tsx/dist/cli.mjs $out/lib/tencentdb-agent-memory/MemoryKnowledge/src/mcp/server.ts"
    fi
  '';

  meta = {
    description = "Team-level memory hub and MCP server for AI Agents by Tencent Cloud";
    homepage = "https://github.com/TencentCloud/TencentDB-Agent-Memory";
    license = lib.licenses.mit;
    mainProgram = "tencentdb-agent-memory";
    platforms = lib.platforms.all;
  };
})
