{
  pins,
  vimUtils,
  pkgs,
  ...
}: let
  mcp-hub = import ./bin.nix {inherit pins pkgs;};
  pin = pins.mcphub-nvim;
  version = pin.branch;
  src = pkgs.fetchFromGitHub {
    inherit (pin.repository) owner repo;
    rev = pin.revision;
    sha256 = pin.hash;
  };
in
  vimUtils.buildVimPlugin {
    pname = "mcphub-nvim";
    inherit src version;

    doCheck = false;

    postInstall = ''
      mkdir -p $out/bundled/mcp-hub/node_modules/.bin
      ln -s ${mcp-hub}/bin/mcp-hub $out/bundled/mcp-hub/node_modules/.bin/mcp-hub
    '';
  }
