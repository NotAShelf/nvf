{lib, ...}: let
  inherit (lib.options) mkEnableOption;
in {
  options.vim.utility.hydra = {
    enable = mkEnableOption "utility for creating custom submodes and menus [nvimtools/hydra.nvim]";
  };
}
