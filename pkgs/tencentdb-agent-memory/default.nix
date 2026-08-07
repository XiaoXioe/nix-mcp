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
        outputHash = "sha256-bh6CmYXsv5CJrjRDkLqXZhPh3Bd1mPQEJlb1jqRfeHI=";
      }
      ''
        export HOME=$TMPDIR
        mkdir -p $TMPDIR/build $out/lib/tencentdb-agent-memory
        cp -r ${finalAttrs.src}/MemoryCore/* $TMPDIR/build/
        chmod -R +w $TMPDIR/build
        cd $TMPDIR/build
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
