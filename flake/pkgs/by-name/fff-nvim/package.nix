{
  lib,
  pins,
  rustPlatform,
  stdenv,
  vimUtils,
  pkgs,
  ...
}: let
  pin = pins.fff-nvim;

  pname = "fff-nvim-lib";
  version = pin.revision;
  src = pkgs.fetchFromGitHub {
    inherit (pin.repository) owner repo;
    rev = pin.revision;
    sha256 = pin.hash;
  };

  fff-nvim-lib = rustPlatform.buildRustPackage {
    inherit pname version src;

    cargoLock = {
      lockFile = "${src}/Cargo.lock";
    };

    cargoBuildFlags = ["-p" "fff-nvim"];
    cargoTestFlags = ["-p" "fff-nvim"];

    doCheck = false;

    env.RUSTFLAGS = lib.optionalString stdenv.hostPlatform.isDarwin "-C link-arg=-undefined -C link-arg=dynamic_lookup";
  };
in
  vimUtils.buildVimPlugin {
    pname = "fff-nvim";
    inherit version src;

    doCheck = false;

    postInstall = let
      ext = stdenv.hostPlatform.extensions.sharedLibrary;
    in ''
      mkdir -p $out/target/release
      ln -s ${fff-nvim-lib}/lib/libfff_nvim${ext} $out/target/release/libfff_nvim${ext}
    '';

    nvimSkipModules = [
      "fff.download"
    ];

    meta = {
      description = "A high-performance Neovim file picker with fuzzy search and frecency scoring";
      homepage = "https://github.com/dmtrKovalenko/fff";
      license = lib.licenses.mit;
      maintainers = [];
    };
  }
