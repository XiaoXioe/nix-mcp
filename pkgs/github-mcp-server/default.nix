{ pkgs, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "github-mcp-server";
  version = "1.7.0";

  src = pkgs.runCommand "${pname}-src"
    {
      nativeBuildInputs = [
        pkgs.curl
        pkgs.cacert
      ];
      outputHashAlgo = "sha256";
      outputHashMode = "recursive";
      outputHash = "sha256-M/eRueThhuvMqb5+TN/DMAJX327MTWTfzcyHS/ZBHzA=";
    }
    ''
      export HOME=$TMPDIR
      export SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt

      mkdir -p $out
      curl -L -o $out/github-mcp-server_Linux_x86_64.tar.gz \
        https://github.com/github/github-mcp-server/releases/download/v${version}/github-mcp-server_Linux_x86_64.tar.gz
      curl -L -o $out/github-mcp-server_Linux_arm64.tar.gz \
        https://github.com/github/github-mcp-server/releases/download/v${version}/github-mcp-server_Linux_arm64.tar.gz
    '';

  nativeBuildInputs = [
    pkgs.autoPatchelfHook
  ];

  buildInputs = [
    pkgs.stdenv.cc.cc.lib
  ];

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin
    if [ "${pkgs.stdenv.hostPlatform.system}" = "aarch64-linux" ]; then
      tar -xzf $src/github-mcp-server_Linux_arm64.tar.gz -C $out/bin github-mcp-server
    else
      tar -xzf $src/github-mcp-server_Linux_x86_64.tar.gz -C $out/bin github-mcp-server
    fi
    chmod +x $out/bin/github-mcp-server
  '';
}
