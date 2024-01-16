{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption;
in {
  options.vim.notes.mind-nvim = {
    enable = mkEnableOption "organizer tool for Neovim.";
  };
}
