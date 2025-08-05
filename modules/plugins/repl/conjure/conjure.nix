{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.modules) mkIf;

  cfg = config.vim.repl.conjure;
in {
  options.vim.repl.conjure = {
    enable = mkEnableOption "Conjure";
  };

  config = mkIf cfg.enable {
    vim.startPlugins = [pkgs.vimPlugins.conjure];
  };
}
