{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.vim.git.vim-fugitive;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = ["vim-fugitive"];
  };
}
