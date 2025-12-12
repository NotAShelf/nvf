{
  lib,
  pins,
  openssl,
  pkg-config,
  rustPlatform,
  stdenv,
  vimUtils,
  makeWrapper,
  pkgs,
  ...
}: let
  # From npins
  pin = pins.avante-nvim;

  pname = "avante-nvim-lib";
  version = pin.branch;
  src = pkgs.fetchFromGitHub {
    inherit (pin.repository) owner repo;
    rev = pin.revision;
    sha256 = pin.hash;
  };

  avante-nvim-lib = rustPlatform.buildRustPackage {
    inherit pname version src;

    cargoHash = "sha256-pTWCT2s820mjnfTscFnoSKC37RE7DAPKxP71QuM+JXQ=";

    nativeBuildInputs = [
      pkg-config
      makeWrapper
      pkgs.perl
    ];

    buildInputs = [
      openssl
    ];

    buildFeatures = ["luajit"];

    checkFlags = [
      # Disabled because they access the network.
      "--skip=test_hf"
      "--skip=test_public_url"
      "--skip=test_roundtrip"
      "--skip=test_fetch_md"
    ];

    env.RUSTFLAGS = lib.optionalString stdenv.hostPlatform.isDarwin "-C link-arg=-undefined -C link-arg=dynamic_lookup";
  };
in
  vimUtils.buildVimPlugin {
    pname = "avante-nvim";
    inherit version src;

    doCheck = false;

    postInstall = let
      ext = stdenv.hostPlatform.extensions.sharedLibrary;
    in ''
      mkdir -p $out/build
      for lib in "avante_repo_map" "avante_templates" "avante_tokenizers" "avante_html2md"; do
        ln -s ${avante-nvim-lib}/lib/lib$lib${ext} $out/build/$lib${ext}
      done
    '';

    nvimSkipModules = [
      # Requires setup with corresponding provider
      "avante.providers.azure"
      "avante.providers.copilot"
      "avante.providers.gemini"
      "avante.providers.ollama"
      "avante.providers.vertex"
      "avante.providers.vertex_claude"
    ];

    meta = {
      description = "Neovim plugin designed to emulate the behaviour of the Cursor AI IDE";
      homepage = "https://github.com/yetone/avante.nvim";
      license = lib.licenses.asl20;
    };
  }
