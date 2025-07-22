{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  cfg = config.vim.utility.nvim-biscuits;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["nvim-biscuits"];
    };
  };
}
