{
  config,
  lib,
  ...
}:
with lib;
with builtins; {
  options.vim.utility.icon-picker = {
    enable = mkEnableOption "Enable nerdfonts icon picker for nvim";
  };
}
