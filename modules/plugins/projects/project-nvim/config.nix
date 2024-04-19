{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.projects.project-nvim;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = [
      "project-nvim"
    ];

    vim.luaConfigRC.project-nvim = entryAnywhere ''
      require('project_nvim').setup(${toLuaObject cfg.setupOpts})
    '';
  };
}
