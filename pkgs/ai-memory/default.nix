{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  zlib,
}:

let
  pname = "ai-memory";
  version = "2.6.2";

  sources = {
    x86_64-linux = {
      url = "https://github.com/akitaonrails/ai-memory/releases/download/v${version}/ai-memory-linux-x86_64.tar.gz";
      hash = "sha256-3HMRj3cnY6EZsD04f29E8Lhm2FSYhRt0qlFSlE7y5lA=";
    };
    aarch64-linux = {
      url = "https://github.com/akitaonrails/ai-memory/releases/download/v${version}/ai-memory-linux-aarch64.tar.gz";
      hash = "sha256-WHy10+4q/LrcKC2x1+6VUVciTXBtUr+JsY314naffpw=";
    };
  };

  system = stdenv.hostPlatform.system;

  hooksSrc = fetchurl {
    url = "https://github.com/akitaonrails/ai-memory/releases/download/v${version}/ai-memory-hooks.tar.gz";
    hash = "sha256-QzQS6v1LnB8ssbjT3+ZbMr57HDYZHyn9N9b/qQWb9Bg=";
  };
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl (
    sources.${system} or (throw "Unsupported platform: ${system}")
  );

  sourceRoot = ".";

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    zlib
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/share/ai-memory/hooks $out/bin/hooks
    cp ai-memory $out/bin/
    chmod +x $out/bin/ai-memory

    tar -xzf ${hooksSrc} -C $out/share/ai-memory/hooks
    cp -r $out/share/ai-memory/hooks/hooks/* $out/bin/hooks/ 2>/dev/null || cp -r $out/share/ai-memory/hooks/* $out/bin/hooks/
    runHook postInstall
  '';

  meta = with lib; {
    description = "Long-term persistent memory and cross-agent handoff engine for AI coding CLIs";
    homepage = "https://github.com/akitaonrails/ai-memory";
    license = licenses.mit;
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "ai-memory";
  };
}
