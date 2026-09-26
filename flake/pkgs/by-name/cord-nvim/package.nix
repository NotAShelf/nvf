{
  lib,
  pins,
  fetchFromGitHub,
  rustPlatform,
  stdenv,
  vimUtils,
}: let
  pin = pins.cord-nvim;

  version = lib.removePrefix "v" pin.version;
  src = fetchFromGitHub {
    inherit (pin.repository) owner repo;
    rev = pin.revision;
    hash = pin.hash;
  };

  cord-server = rustPlatform.buildRustPackage {
    pname = "cord";
    inherit version src;

    cargoHash = "sha256-f2bYDfWFfOm2H4iy0FS4g3NFW7uTB5/1CE7AQSr5llM=";

    doCheck = false;

    env.RUSTFLAGS = lib.optionalString stdenv.hostPlatform.isDarwin "-C link-arg=-undefined -C link-arg=dynamic_lookup";

    meta.mainProgram = "cord";
  };
in
  vimUtils.buildVimPlugin {
    pname = "cord-nvim";
    inherit version src;

    doCheck = false;

    postPatch = ''
      substituteInPlace lua/cord/server/fs/init.lua \
        --replace-fail "or M.get_data_path()" "or '${cord-server}'"

      substituteInPlace lua/cord/api/config/init.lua \
        --replace-fail "update = 'fetch'," "update = 'none'," \
        --replace-fail "auto_update = true," "auto_update = false,"
    '';

    meta = {
      description = "Discord rich presence plugin for Neovim";
      homepage = "https://github.com/vyfor/cord.nvim";
      license = lib.licenses.asl20;
    };
  }
