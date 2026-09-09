{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  zlib,
}:

let
  pname = "ai-memory";
  version = "2.1.1";

  sources = {
    x86_64-linux = {
      url = "https://github.com/akitaonrails/ai-memory/releases/download/v${version}/ai-memory-linux-x86_64.tar.gz";
      hash = "sha256-UFfSKem9zEiOKEoRuWBrEwtu1syseeVB9Ctt/rBF6nM=";
    };
    aarch64-linux = {
      url = "https://github.com/akitaonrails/ai-memory/releases/download/v${version}/ai-memory-linux-aarch64.tar.gz";
      hash = "sha256-ctoSTCqas4Q+RL7y0bZqDyMTpLVXrTFXjZmyRwxr6Ww=";
    };
  };

  system = stdenv.hostPlatform.system;

  hooksSrc = fetchurl {
    url = "https://github.com/akitaonrails/ai-memory/releases/download/v${version}/ai-memory-hooks.tar.gz";
    hash = "sha256-skJeZFZuRVRz4Gc0UFTQBoA+gJDoKOuTi3e6hmhRi9Y=";
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
