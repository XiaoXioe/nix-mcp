{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  zlib,
}:

let
  pname = "ai-memory";
  version = "1.39.0";

  sources = {
    x86_64-linux = {
      url = "https://github.com/akitaonrails/ai-memory/releases/download/v${version}/ai-memory-linux-x86_64.tar.gz";
      hash = "sha256-YhA0vD+DtCW+hDcEswHBUz+KuqGuUosNpdCeYFJVn0A=";
    };
    aarch64-linux = {
      url = "https://github.com/akitaonrails/ai-memory/releases/download/v${version}/ai-memory-linux-aarch64.tar.gz";
      hash = "sha256-7KizstxypKROgooKGTT/jgco62MivMt/gz1YGFEk/uQ=";
    };
  };

  system = stdenv.hostPlatform.system;

  hooksSrc = fetchurl {
    url = "https://github.com/akitaonrails/ai-memory/releases/download/v${version}/ai-memory-hooks.tar.gz";
    hash = "sha256-VdMCKD3MspBMaZgTRrtU0p0zoE6jt/snYS/4dBoM/vg=";
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
