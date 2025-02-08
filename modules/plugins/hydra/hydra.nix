{lib, ...}: let
  #inherit (lib) types;
  inherit (lib.options) mkEnableOption;
in {
  options.vim.hydra = {
    enable = mkEnableOption "Creating custom submodes and menus [nvimtools/hydra.nvim]";
  };
}
