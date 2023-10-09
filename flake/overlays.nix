{
  inputs,
  pkgs,
  ...
}: let
  inherit (import ../configuration.nix inputs) neovimConfiguration mainConfig;

  buildPkg = pkgs: modules: (neovimConfiguration {inherit pkgs modules;}).neovim;

  nixConfig = mainConfig false;
  maximalConfig = mainConfig true;
  tidalConfig = {config.vim.tidal.enable = true;};
in {
  flake.overlays.default = _final: prev: {
    inherit neovimConfiguration;
    neovim-nix = buildPkg prev [nixConfig];
    neovim-maximal = buildPkg prev [maximalConfig];
    neovim-tidal = buildPkg prev [tidalConfig];
    devPkg = buildPkg pkgs [nixConfig {config.vim.languages.html.enable = pkgs.lib.mkForce true;}];
  };
}
