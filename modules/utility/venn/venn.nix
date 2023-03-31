{
  config,
  lib,
  ...
}:
with lib;
with builtins; {
  options.vim.utility.venn-nvim = {
    enable = mkEnableOption "draw ASCII diagrams in Neovim";
  };
}
