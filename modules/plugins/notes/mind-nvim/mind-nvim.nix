{lib, ...}: let
  inherit (lib.options) mkEnableOption;
in {
  options.vim.notes.mind-nvim = {
    enable = mkEnableOption "note organizer tool for Neovim [mind-nvim]";
  };
}
