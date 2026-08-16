{
  lib,
  pins,
  rustPlatform,
  stdenv,
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
in
  rustPlatform.buildRustPackage {
    pname = "jupynvim-core";
    inherit version;

    src = src + "/core";

    cargoHash = "sha256-cZKHYCFtzU1ULNp7TY/4/l6SrzGF3ghnBF5y5nvxuWw=";

    doCheck = false;

    env.RUSTFLAGS = lib.optionalString stdenv.hostPlatform.isDarwin "-C link-arg=-undefined -C link-arg=dynamic_lookup";
  }
