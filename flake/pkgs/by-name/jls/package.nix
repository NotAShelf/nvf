# based on <https://github.com/idelice/jls/blob/master/default.nix>
{
  lib,
  jdk25_headless,
  maven,
  lombok,
  protobuf_25,
  lombokSupport ? true,
  makeWrapper,
  fetchFromGitHub,
}: let
  inherit (lib.meta) getExe;

  jdk = jdk25_headless;
  java = getExe jdk;
  jlinkVmOptions =
    map
    (option: ''
      --add-flags "${option}" \
    '')
    [
      "--add-modules jdk.jdeps"
      "--add-exports jdk.compiler/com.sun.tools.javac.api=ALL-UNNAMED"
      "--add-exports jdk.compiler/com.sun.tools.javac.code=ALL-UNNAMED"
      "--add-exports jdk.compiler/com.sun.tools.javac.comp=ALL-UNNAMED"
      "--add-exports jdk.compiler/com.sun.tools.javac.file=ALL-UNNAMED"
      "--add-exports jdk.compiler/com.sun.tools.javac.jvm=ALL-UNNAMED"
      "--add-exports jdk.compiler/com.sun.tools.javac.main=ALL-UNNAMED"
      "--add-exports jdk.compiler/com.sun.tools.javac.tree=ALL-UNNAMED"
      "--add-exports jdk.compiler/com.sun.tools.javac.model=ALL-UNNAMED"
      "--add-exports jdk.compiler/com.sun.tools.javac.parser=ALL-UNNAMED"
      "--add-exports jdk.compiler/com.sun.tools.javac.processing=ALL-UNNAMED"
      "--add-exports jdk.compiler/com.sun.tools.javac.util=ALL-UNNAMED"
      "--add-opens jdk.compiler/com.sun.tools.javac.api=ALL-UNNAMED"
      "--add-opens jdk.compiler/com.sun.tools.javac.tree=ALL-UNNAMED"
      "--add-opens jdk.compiler/com.sun.tools.javac.code=ALL-UNNAMED"
      "--add-opens jdk.compiler/com.sun.tools.javac.comp=ALL-UNNAMED"
      "--add-opens jdk.compiler/com.sun.tools.javac.file=ALL-UNNAMED"
      "--add-opens jdk.compiler/com.sun.tools.javac.jvm=ALL-UNNAMED"
      "--add-opens jdk.compiler/com.sun.tools.javac.model=ALL-UNNAMED"
      "--add-opens jdk.compiler/com.sun.tools.javac.parser=ALL-UNNAMED"
      "--add-opens jdk.compiler/com.sun.tools.javac.processing=ALL-UNNAMED"
      "--add-opens jdk.compiler/com.sun.tools.javac.util=ALL-UNNAMED"
      "--add-opens jdk.compiler/com.sun.tools.javac.main=ALL-UNNAMED"
    ];
  wrapperFlags = ''
    ${lib.concatStringsSep " " jlinkVmOptions} \
    --add-flags "\$JLS_JVM_OPTS" \
    --add-flags "-Djava.util.logging.config.file=$out/share/jls/logging.properties" \
    ${lib.optionalString lombokSupport ''--add-flags "-Dorg.javacs.lombokPath=${lombok}/share/lombok.jar"''} \
    --add-flags "-classpath '$out/share/jls/classpath/*'" \
    --set-default JLS_JVM_OPTS "-Xmx2g -Xms512m -XX:MaxHeapFreeRatio=50 -XX:MinHeapFreeRatio=20 -XX:+UseStringDeduplication" \
  '';
in
  maven.buildMavenPackage (finalAttrs: {
    pname = "jls";
    version = "0.6.1";

    src = fetchFromGitHub {
      owner = "idelice";
      repo = "jls";
      tag = "v${finalAttrs.version}";
      hash = "sha256-kZ96OsCMtpS3diUT/4+TEnzNb2G4LfDdrrSKuhIM9NU=";
    };

    mvnJdk = jdk;
    mvnHash = "sha256-E/ZNOGIB/00dfhPsagwJUV6TWHCY7Jb5Ewlvyxs3sRI=";
    mvnParameters = "-DskipTests";

    nativeBuildInputs = [
      makeWrapper
      protobuf_25
    ];

    preBuild = ''
      bash ./scripts/gen_proto.sh
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin $out/share/jls/
      cp -r dist/classpath $out/share/jls/
      install -Dm644 scripts/logging.properties $out/share/jls

      makeWrapper ${java} $out/bin/jls \
        ${wrapperFlags} \
        --add-flags "org.javacs.Main"
      makeWrapper ${java} $out/bin/jls-dap \
        ${wrapperFlags} \
        --add-flags "org.javacs.debug.JavaDebugServer"

      runHook postInstall
    '';

    meta = {
      description = "Java Language Server for Neovim";
      license = lib.licenses.mit;
      mainProgram = "jls";
    };
  })
