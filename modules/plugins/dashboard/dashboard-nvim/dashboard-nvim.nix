{lib, ...}: let
  inherit (lib.options) mkEnableOption;
in {
  options.vim.dashboard.dashboard-nvim = {
    enable = mkEnableOption "Fancy and Blazing Fast start screen plugin of neovim [dashboard.nvim]";
  };
}
