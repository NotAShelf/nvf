{
  lib,
  pins,
  rustPlatform,
  stdenv,
  vimUtils,
  pkgs,
  ...
}: let
  # From npins
  pin = pins.jupynvim;

  version = pin.revision;
  src = pkgs.fetchFromGitHub {
    inherit (pin.repository) owner repo;
    rev = pin.revision;
    sha256 = pin.hash;
  };

  # The Rust backend (`jupynvim-core`) lives in the `core/` subdirectory of the
  # plugin source, while the Lua frontend lives at the repo root.
  jupynvim-core = rustPlatform.buildRustPackage {
    pname = "jupynvim-core";
    inherit version;
    src = src + "/core";

    cargoHash = "sha256-cZKHYCFtzU1ULNp7TY/4/l6SrzGF3ghnBF5y5nvxuWw=";

    doCheck = false;

    env.RUSTFLAGS = lib.optionalString stdenv.hostPlatform.isDarwin "-C link-arg=-undefined -C link-arg=dynamic_lookup";
  };
in
  vimUtils.buildVimPlugin {
    pname = "jupynvim";
    inherit version src;

    doCheck = false;

    postInstall = ''
      mkdir -p $out/core/target/release
      cp ${jupynvim-core}/bin/jupynvim-core $out/core/target/release/jupynvim-core
    '';

    meta = {
      description = "Jupyter notebooks in Neovim with a native Rust backend";
      homepage = "https://github.com/sheng-tse/jupynvim";
      license = lib.licenses.mit;
    };
  }
