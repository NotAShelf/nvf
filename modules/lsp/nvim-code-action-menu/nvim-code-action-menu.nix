{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.lsp;
in {
  options.vim.lsp = {
    nvimCodeActionMenu = {
      enable = mkEnableOption "nvim code action menu";
    };
  };
}
