{
  lib,
  callPackage,
  pins,
  pkgs,
  vimUtils,
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

  jupynvim-core = callPackage ../jupynvim-core/package.nix {};
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
