{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.dashboard.dashboard-nvim;
in {
  options.vim.dashboard.dashboard-nvim = {
    enable = mkEnableOption "dashboard-nvim";
  };

  config = mkIf cfg.enable {
    vim.startPlugins = [
      "dashboard-nvim"
    ];

    vim.luaConfigRC.dashboard-nvim = nvim.dag.entryAnywhere ''
      require("dashboard").setup{
      }
    '';
  };
}
