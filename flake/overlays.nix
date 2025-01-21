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
  flake.overlays.default = final: _prev: {
    inherit neovimConfiguration;
    neovim-nix = buildPkg final [nixConfig];
    neovim-maximal = buildPkg final [maximalConfig];
    devPkg = buildPkg pkgs [nixConfig {config.vim.languages.html.enable = pkgs.lib.mkForce true;}];
  };
}
