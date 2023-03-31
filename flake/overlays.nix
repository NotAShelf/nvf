{inputs, ...}: let
  inherit (import ../extra.nix inputs) neovimConfiguration mainConfig;

  buildPkg = pkgs: modules:
    (neovimConfiguration {inherit pkgs modules;})
    .neovim;

  nixConfig = mainConfig false;
  maximalConfig = mainConfig true;
  tidalConfig = {config.vim.tidal.enable = true;};
in {
  flake.overlays.default = _final: prev: {
    inherit neovimConfiguration;
    neovim-nix = buildPkg prev [nixConfig];
    neovim-maximal = buildPkg prev [maximalConfig];
    neovim-tidal = buildPkg prev [tidalConfig];
  };
}
