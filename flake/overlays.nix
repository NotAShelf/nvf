{
  pkgs,
  lib,
  ...
}: let
  inherit (lib.nvim) neovimConfiguration;

  buildPkg = pkgs: modules: (neovimConfiguration {inherit pkgs modules;}).neovim;

  nixConfig = import ../configuration.nix false;
  maximalConfig = import ../configuration.nix true;
in {
  flake.overlays.default = _final: prev: {
    inherit neovimConfiguration;
    neovim-nix = buildPkg prev [nixConfig];
    neovim-maximal = buildPkg prev [maximalConfig];
    devPkg = buildPkg pkgs [nixConfig {config.vim.languages.html.enable = pkgs.lib.mkForce true;}];
  };
}
