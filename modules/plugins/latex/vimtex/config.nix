{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.vim.latex.vimtex;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = ["vimtex"];
  };
}
