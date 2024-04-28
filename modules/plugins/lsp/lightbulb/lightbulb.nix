{lib, ...}: let
  inherit (lib.options) mkEnableOption;
in {
  options.vim.lsp = {
    lightbulb = {
      enable = mkEnableOption "Lightbulb for code actions. Requires an emoji font";
    };
  };
}
