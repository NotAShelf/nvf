{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  fetchYarnDeps,
  fetchurl,
  yarnConfigHook,
  yarnBuildHook,
  yarnInstallHook,
  nodejs,
  runCommand,
  patch,
  nix-update-script,
}: let
  version = "1.1.0";

  upstream = fetchFromGitHub {
    owner = "marcoroth";
    repo = "stimulus-lsp";
    tag = "v${version}";
    hash = "sha256-QAXQKZoFvqhnbAIi9fnJ7pV8fXah0NjwxdrqKB5e5Vw=";
  };

  # `fetchYarnDeps` doesn't support tarballs so we need to patch this manually
  stimulusTarball = fetchurl {
    url = "https://github.com/hotwired/dev-builds/archive/refs/tags/@hotwired/stimulus/8cbca6d.tar.gz";
    hash = "sha256-2iRIiwXmdcSw7y3CQNIPt6duwZuVvDvdU/FEdqcnzW4=";
  };

  src = runCommand "stimulus-lsp-server-patched" {nativeBuildInputs = [patch];} ''
    cp -r ${upstream}/server $out
    chmod -R +w $out
    cp '${stimulusTarball}' $out/hotwired-stimulus.tar.gz
    patch -d $out -p1 < '${./0001-use-local-hotwired.patch}'
    patch -d $out -p1 < '${./0002-add-types-node.patch}'
  '';
in
  stdenvNoCC.mkDerivation {
    pname = "stimulus-language-server";
    inherit version src;

    offlineCache = fetchYarnDeps {
      yarnLock = "${src}/yarn.lock";
      hash = "sha256-UvojI/Ow602Q+iiwRpSgxm4DV0IJ0sURicdgghmpBsU=";
    };

    nativeBuildInputs = [
      yarnConfigHook
      yarnBuildHook
      yarnInstallHook
      nodejs
    ];

    passthru.updateScript = nix-update-script {};

    meta = {
      description = "Intelligent Stimulus tooling";
      homepage = "https://hotwire.io/ecosystem/tooling/stimulus-lsp";
      changelog = "https://github.com/marcoroth/stimulus-lsp/releases/tag/v${version}";
      license = lib.licenses.mit;
      mainProgram = "stimulus-language-server";
    };
  }
