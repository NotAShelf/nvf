{
  config,
  lib,
  ...
}:
with lib;
with builtins; {
  options.vim.utility.colorizer = {
    enable = mkEnableOption "ccc color picker for neovim";
  };
}
