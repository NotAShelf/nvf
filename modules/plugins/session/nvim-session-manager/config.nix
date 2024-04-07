{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf optionals mkMerge mkBinding nvim;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.session.nvim-session-manager;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins =
        [
          "nvim-session-manager"
          "plenary-nvim"
        ]
        ++ optionals cfg.usePicker ["dressing-nvim"];

      maps.normal = mkMerge [
        (mkBinding cfg.mappings.loadSession ":SessionManager load_session<CR>" "Load session")
        (mkBinding cfg.mappings.deleteSession ":SessionManager delete_session<CR>" "Delete session")
        (mkBinding cfg.mappings.saveCurrentSession ":SessionManager save_current_session<CR>" "Save current session")
        (mkBinding cfg.mappings.loadLastSession ":SessionManager load_last_session<CR>" "Load last session")
        # TODO: load_current_dir_session
      ];

      luaConfigRC.nvim-session-manager = nvim.dag.entryAnywhere ''
        local Path = require('plenary.path')
        local sm = require('session_manager.config')
        require('session_manager').setup(${toLuaObject cfg.setupOpts})
      '';
    };
  };
}
