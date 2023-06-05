{
  config,
  lib,
  ...
}:
with lib;
with builtins; {
  options.vim.notes.mind-nvim = {
    enable = mkEnableOption "organizer tool for Neovim.";
  };
}
