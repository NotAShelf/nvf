{
  config,
  lib,
  ...
}:
with lib;
with builtins; {
  options.vim.tabline.nvimBufferline = {
    enable = mkEnableOption "nvim-bufferline-lua";
  };
}
