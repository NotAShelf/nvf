{lib, ...}:
with lib;
with builtins; {
  options.vim.utility.icon-picker = {
    enable = mkEnableOption "nerdfonts icon picker for nvim";
  };
}
