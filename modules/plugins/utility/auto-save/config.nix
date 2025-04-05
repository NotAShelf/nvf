{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.vim.auto-save;
in {
  vim.lazy.plugins."auto-save.nvim" = mkIf cfg.enable {
    package = pkgs.vimPlugins.auto-save-nvim;
    setupModule = "auto-save";
    inherit (cfg) setupOpts;
  };
}
