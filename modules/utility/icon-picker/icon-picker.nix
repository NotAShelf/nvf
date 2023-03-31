{
  config,
  lib,
  ...
}:
with lib;
with builtins; {
  options.vim.utility.icon-picker = {
    enable = mkEnableOption "Nerdfonts icon picker for nvim";
  };
}
