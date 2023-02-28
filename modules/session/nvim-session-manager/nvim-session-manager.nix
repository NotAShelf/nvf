{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.session.nvim-session-manager;
in {
  options.vim.session.nvim-session-manager = {
    enable = mkEnableOption "Enable nvim-session-manager";
  };
}
