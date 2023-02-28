{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.utility.venn-nvim;
in {
  options.vim.utility.venn-nvim = {
    enable = mkEnableOption "draw ASCII diagrams in Neovim";
  };
}
