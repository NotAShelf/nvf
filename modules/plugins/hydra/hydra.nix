{lib, ...}: let
  #inherit (lib) types;
  inherit (lib.options) mkEnableOption;
in {
  options.vim.utility.hydra = {
    enable = mkEnableOption "utility for creating custom submodes and menus [nvimtools/hydra.nvim]";
  };
}
