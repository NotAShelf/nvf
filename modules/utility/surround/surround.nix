{lib, ...}:
with lib;
with builtins; {
  options.vim.utility.surround = {
    enable = mkEnableOption "nvim-surround: add/change/delete surrounding delimiter pairs with ease";
  };
}
