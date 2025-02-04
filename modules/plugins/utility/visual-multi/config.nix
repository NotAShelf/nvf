{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  cfg = config.vim.utility.visual-multi;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = [pkgs.vimPlugins.vim-visual-multi];
    };
  };
}
