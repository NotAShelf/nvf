{
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
  version = pin.branch;
  src = pkgs.fetchFromGitHub {
    inherit (pin.repository) owner repo;
    rev = pin.revision;
    sha256 = pin.hash;
  };

  avante-nvim-lib = rustPlatform.buildRustPackage {
    pname = "avante-nvim-lib";
    inherit version src;

    cargoHash = "sha256-8mBpzndz34RrmhJYezd4hLrJyhVL4S4IHK3plaue1k8=";

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
      "avante.providers.vertex_claude"
      "avante.providers.ollama"
    ];
  }
