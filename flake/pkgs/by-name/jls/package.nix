# based on <https://github.com/idelice/jls/blob/master/default.nix>
{
  lib,
  fetchFromGitHub,
  makeWrapper,
  jdk25_headless,
  maven,
  lombok,
  protobuf_25,
  lombokSupport ? true,
}: let
  jdk = jdk25_headless;

  # Basically copy JLINK_VM_OPTIONS in upstream's dist/launch_linux.sh
  javacPackages = ["api" "code" "comp" "file" "jvm" "main" "model" "parser" "platform" "processing" "tree" "util"];
  jvmFlags =
    ["--add-modules jdk.jdeps"]
    ++ map (p: "--add-exports jdk.compiler/com.sun.tools.javac.${p}=ALL-UNNAMED") javacPackages
    ++ map (p: "--add-opens jdk.compiler/com.sun.tools.javac.${p}=ALL-UNNAMED") javacPackages
    ++ [
      "\\$JLS_JVM_OPTS"
      "-Djava.util.logging.config.file=${placeholder "out"}/share/jls/logging.properties"
    ]
    ++ lib.optional lombokSupport "-Dorg.javacs.lombokPath=${lombok}/share/lombok.jar"
    ++ ["-classpath '${placeholder "out"}/share/jls/classpath/*'"];

  wrapperArgs = lib.concatMapStringsSep " " (flag: ''--add-flags "${flag}"'') jvmFlags;
in
  maven.buildMavenPackage (finalAttrs: {
    pname = "jls";
    version = "0.9.0";

    src = fetchFromGitHub {
      owner = "idelice";
      repo = "jls";
      tag = "v${finalAttrs.version}";
      hash = "sha256-9LPLNEKzsCXMdSDdm5WyzOMp9BoHxBWdjxgxJSqz1LM=";
    };

    mvnJdk = jdk;
    mvnHash = "sha256-PNBuentUs+bv7IKK1mg9ZbisW7FtsENX/0bpkJ6qa6w=";

    # Upstream test sources do not compile as of 0.9.0.
    mvnParameters = "-Dmaven.test.skip=true";

    nativeBuildInputs = [
      makeWrapper
      protobuf_25
    ];

    preBuild = ''
      bash ./scripts/gen_proto.sh
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/jls
      cp -r dist/classpath $out/share/jls/
      install -Dm644 scripts/logging.properties $out/share/jls

      for bin in jls:org.javacs.Main jls-dap:org.javacs.debug.JavaDebugServer; do
        makeWrapper ${lib.getExe jdk} $out/bin/''${bin%%:*} \
          ${wrapperArgs} \
          --set-default JLS_JVM_OPTS "-Xmx2g -Xms512m -XX:MaxHeapFreeRatio=50 -XX:MinHeapFreeRatio=20 -XX:+UseStringDeduplication" \
          --add-flags "''${bin#*:}"
      done

      runHook postInstall
    '';

    meta = {
      description = "Java Language Server for Neovim";
      homepage = "https://github.com/idelice/jls";
      changelog = "https://github.com/idelice/jls/releases/tag/v${finalAttrs.version}";
      license = lib.licenses.mit;
      mainProgram = "jls";
    };
  })
