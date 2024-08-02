{lib, ...}: let
  inherit (lib.options) mkEnableOption;
in {
  imports = [
    ./fastaction-nvim
  ];
  options.vim.lsp.code-actions = {
    enable = mkEnableOption "code-actions. Setting this to `false` will disable all code action plugins.";
  };
}
