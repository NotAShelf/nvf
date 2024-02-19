{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;

  cfg = config.vim.dashboard.dashboard-nvim;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = [
        "dashboard-nvim"
      ];

      luaConfigRC.dashboard-nvim = entryAnywhere ''
        require("dashboard").setup{}
      '';
    };
  };
}
