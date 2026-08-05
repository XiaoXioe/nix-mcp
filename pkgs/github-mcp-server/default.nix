{
  lib,
  stdenv,
  runCommand,
  curl,
  cacert,
  autoPatchelfHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "github-mcp-server";
  version = "1.8.0";

  src =
    runCommand "${finalAttrs.pname}-src"
      {
        nativeBuildInputs = [
          curl
          cacert
        ];
        outputHashAlgo = "sha256";
        outputHashMode = "recursive";
        outputHash = "sha256-6yx+zKL7gAQYl0YgAsdbS1aQAedBhtb4zmIlZv5vfms=";
      }
      ''
        export HOME=$TMPDIR
        export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt

        mkdir -p $out
        curl -L -o $out/github-mcp-server_Linux_x86_64.tar.gz \
          https://github.com/github/github-mcp-server/releases/download/v${finalAttrs.version}/github-mcp-server_Linux_x86_64.tar.gz
        curl -L -o $out/github-mcp-server_Linux_arm64.tar.gz \
          https://github.com/github/github-mcp-server/releases/download/v${finalAttrs.version}/github-mcp-server_Linux_arm64.tar.gz
      '';

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    stdenv.cc.cc.lib
  ];

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin
    if [ "${stdenv.hostPlatform.system}" = "aarch64-linux" ]; then
      tar -xzf $src/github-mcp-server_Linux_arm64.tar.gz -C $out/bin github-mcp-server
    else
      tar -xzf $src/github-mcp-server_Linux_x86_64.tar.gz -C $out/bin github-mcp-server
    fi
    chmod +x $out/bin/github-mcp-server
  '';

  meta = {
    description = "Official GitHub Model Context Protocol (MCP) server";
    homepage = "https://github.com/github/github-mcp-server";
    license = lib.licenses.mit;
    mainProgram = "github-mcp-server";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
})
