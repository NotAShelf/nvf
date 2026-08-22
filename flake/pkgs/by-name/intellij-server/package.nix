{
  lib,
  stdenv,
  fetchurl,
  gnutar,
  unzip,
  autoPatchelfHook,
  zlib,
}: let
  inherit (lib.attrsets) attrNames;
  inherit (lib.lists) optionals;

  platformInfo = {
    x86_64-linux = {
      suffix = "";
      ext = "tar.gz";
      sha256 = "caa4d121236ce5c8904695a87be375a68fada9b9ca4231450773f9fd9d78c3c3";
      unpack = file: out: "tar -xf ${file} --strip-components=1 -C ${out}";
    };
    aarch64-linux = {
      suffix = "-aarch64";
      ext = "tar.gz";
      sha256 = "38947d29fd8e7589f8fbd5794b2e580d40837cde8e60ca0e20b2cb210ea8076e";
      unpack = file: out: "tar -xf ${file} --strip-components=1 -C ${out}";
    };
    aarch64-darwin = {
      suffix = "-aarch64";
      ext = "sit";
      sha256 = "04cecd4fd04bc42ca957e006367d5a42ca2de6b72e5f5149470cc5c701146da4";
      unpack = file: out: "unzip -q ${file} -d ${out}";
    };
  };

  sys = platformInfo.${stdenv.hostPlatform.system};
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "intellij-server";
    version = "263.3533.0";

    src = fetchurl {
      url = "https://download.jetbrains.com/language-server/intellij-server/${finalAttrs.version}/intellij-server-${finalAttrs.version}${sys.suffix}.${sys.ext}";
      inherit (sys) sha256;
    };

    nativeBuildInputs = optionals stdenv.isLinux [gnutar autoPatchelfHook] ++ optionals stdenv.isDarwin [unzip];

    buildInputs =
      [zlib]
      ++ optionals stdenv.isLinux [
        stdenv.cc.cc.lib
      ];

    autoPatchelfIgnoreMissingDeps = true;

    unpackPhase = ''
      runHook preUnpack
      mkdir -p source
      ${sys.unpack "$src" "source"}
      runHook postUnpack
    '';

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r source/* $out/
      runHook postInstall
    '';

    meta = with lib; {
      description = "Standalone JetBrains IntelliJ IDEA language server";
      mainProgram = "intellij-server";
      homepage = "https://blog.jetbrains.com/idea/2026/08/intellij-idea-goes-lsp/";
      license = licenses.unfree;
      platforms = attrNames platformInfo;
    };
  })
