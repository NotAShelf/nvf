{
  config,
  lib,
  ...
}:
with lib;
with builtins; {
  options.vim.utility.diffview-nvim = {
    enable = mkEnableOption "Enable diffview-nvim";
  };
}
