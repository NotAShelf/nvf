{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.git;
in {
  options.vim.git = {
    enable = mkEnableOption "Git support";

    gitsigns = {
      enable = mkEnableOption "gitsigns";

      codeActions = mkEnableOption "gitsigns codeactions through null-ls";
    };
  };
}
