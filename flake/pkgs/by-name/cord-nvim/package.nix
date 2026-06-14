{
  lib,
  pins,
  fetchFromGitHub,
  rustPlatform,
  stdenv,
  vimUtils,
}: let
  pin = pins.cord-nvim;

  pname = "cord";
  version = pin.revision;
  src = fetchFromGitHub {
    inherit (pin.repository) owner repo;
    rev = pin.revision;
    sha256 = pin.hash;
  };

  cord-server = rustPlatform.buildRustPackage {
    inherit pname version src;

    postPatch = ''
      substituteInPlace .github/server-version.txt \
        --replace-fail "2.3.13" "${version}"
    '';

    cargoHash = "sha256-/O+jOaA0PinUiEVILNEF+vUS7Kh3XAwWyFqSvD54rGM=";

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
