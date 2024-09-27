{lib, ...}: let
  inherit (lib.options) mkEnableOption;
in {
  options.vim.lsp = {
    otter = {
      enable = mkEnableOption "trouble lsp for markup languages";
    };
  };
}
