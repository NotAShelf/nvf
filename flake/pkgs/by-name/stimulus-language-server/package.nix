{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  fetchYarnDeps,
  fetchurl,
  applyPatches,
  yarnConfigHook,
  yarnBuildHook,
  yarnInstallHook,
  nodejs,
  nix-update-script,
}: let
  version = "1.1.2";

  upstream = fetchFromGitHub {
    owner = "marcoroth";
    repo = "stimulus-lsp";
    tag = "v${version}";
    hash = "sha256-zF7mz4u+MaJHJM09NxhlTO6TJgkUOhVAmlBKgjsHb0k=";
  };

  # `fetchYarnDeps` doesn't support tarballs so we need to patch this manually
  stimulusTarball = fetchurl {
    url = "https://github.com/hotwired/dev-builds/archive/refs/tags/@hotwired/stimulus/8cbca6d.tar.gz";
    hash = "sha256-2iRIiwXmdcSw7y3CQNIPt6duwZuVvDvdU/FEdqcnzW4=";
  };

  src = applyPatches {
    name = "stimulus-lsp-server-patched";
    src = "${upstream}/server";
    patches = [
      ./0001-use-local-hotwired.patch
      ./0002-add-types-node.patch
    ];

    postPatch = ''
      install -Dm755 ${stimulusTarball} hotwired-stimulus.tar.gz
    '';
  };
in
  stdenvNoCC.mkDerivation {
    pname = "stimulus-language-server";
    inherit version src;

    offlineCache = fetchYarnDeps {
      yarnLock = "${src}/yarn.lock";
      hash = "sha256-FFHWHuwsIkNIqMkGDoUKKz6Ur7vABl4Swja+LtpFXcA=";
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
