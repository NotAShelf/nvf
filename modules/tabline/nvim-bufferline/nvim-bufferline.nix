{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.tabline.nvimBufferline;
in {
  options.vim.tabline.nvimBufferline = {
    enable = mkEnableOption "nvim-bufferline-lua";
  };
}
