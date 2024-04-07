{lib, ...}: let
  inherit (lib.options) mkEnableOption;
in {
  options.vim.dashboard.alpha = {
    enable = mkEnableOption "fast and fully programmable greeter for neovim [alpha.mvim]";
  };
}
