{
  config,
  lib,
  ...
}:
with lib;
with builtins; {
  options.vim.session.nvim-session-manager = {
    enable = mkEnableOption "Enable nvim-session-manager";
  };
}
