{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  cfg = config.vim.utility.sleuth;
in {
  vim.startPlugins = mkIf cfg.enable ["vim-sleuth"];
}
