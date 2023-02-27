{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.minimap.minimap-vim;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = [
      pkgs.code-minimap
      "minimap-vim"
    ];
  };
}
