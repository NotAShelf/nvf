{lib, ...}: let
  inherit (lib.options) mkEnableOption;
in {
  options.vim.utility.icon-picker = {
    enable = mkEnableOption "nerdfonts icon picker for nvim";
  };
}
