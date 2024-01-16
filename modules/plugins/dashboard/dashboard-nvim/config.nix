{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf nvim;

  cfg = config.vim.dashboard.dashboard-nvim;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = [
      "dashboard-nvim"
    ];

    vim.luaConfigRC.dashboard-nvim = nvim.dag.entryAnywhere ''
      require("dashboard").setup{}
    '';
  };
}
