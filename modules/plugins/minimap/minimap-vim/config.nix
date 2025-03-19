{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.binds) pushDownDefault;

  cfg = config.vim.minimap.minimap-vim;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["minimap-vim"];
      extraPackages = [pkgs.code-minimap];

      binds.whichKey.register = pushDownDefault {
        "<leader>m" = "+Minimap";
      };
    };
  };
}
