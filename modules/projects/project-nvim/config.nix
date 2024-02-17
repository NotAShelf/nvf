{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf nvim;

  cfg = config.vim.projects.project-nvim;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = [
      "project-nvim"
    ];

    vim.luaConfigRC.project-nvim = nvim.dag.entryAnywhere ''
      require('project_nvim').setup(${nvim.lua.toLuaObject cfg.setupOpts})
    '';
  };
}
