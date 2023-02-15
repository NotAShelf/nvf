{inputs, ...}: let
  inherit (import ../extra.nix inputs) neovimConfiguration mainConfig;

  tidalConfig = {
    config.vim.tidal.enable = true;
  };

  buildPkg = pkgs: modules:
    (neovimConfiguration {
      inherit pkgs modules;
    })
    .neovim;

  nixConfig = mainConfig false;
  maximalConfig = mainConfig true;
in {
  flake.overlays.default = final: prev: {
    inherit neovimConfiguration;
    neovim-nix = buildPkg prev [nixConfig];
    neovim-maximal = buildPkg prev [maximalConfig];
    neovim-tidal = buildPkg prev [tidalConfig];
  };
}
