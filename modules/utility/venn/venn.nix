{
  config,
  lib,
  ...
}:
with lib;
with builtins; {
  options.vim.utility.venn-nvim = {
    enable = mkEnableOption "Enable venn.nvim: draw ASCII diagrams in Neovim";
  };
}
