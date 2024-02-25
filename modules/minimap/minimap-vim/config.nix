{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf defaultAttributes;

  cfg = config.vim.minimap.minimap-vim;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = [
      pkgs.code-minimap
      "minimap-vim"
    ];

    vim.binds.whichKey.register = defaultAttributes {
      "<leader>m" = "+Minimap";
    };
  };
}
