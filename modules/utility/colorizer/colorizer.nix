{
  config,
  lib,
  ...
}:
with lib;
with builtins; {
  options.vim.utility.colorizer = {
    enable = mkEnableOption "Enable ccc color picker for neovim";
  };
}
