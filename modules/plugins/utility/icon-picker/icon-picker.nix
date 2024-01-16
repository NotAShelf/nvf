{lib, ...}: let
  inherit (lib) mkEnableOption;
in {
  options.vim.utility.icon-picker = {
    enable = mkEnableOption "nerdfonts icon picker for nvim";
  };
}
