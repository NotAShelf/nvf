{
  config,
  lib,
  ...
}:
with lib;
with builtins; {
  options.vim.tabline.nvimBufferline = {
    enable = mkEnableOption "Enable nvim-bufferline-lua as a bufferline";
  };
}
