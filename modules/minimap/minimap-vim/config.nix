{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf pushDownDefault;

  cfg = config.vim.minimap.minimap-vim;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = [
      pkgs.code-minimap
      "minimap-vim"
    ];

    vim.binds.whichKey.register = pushDownDefault {
      "<leader>m" = "+Minimap";
    };
  };
}
