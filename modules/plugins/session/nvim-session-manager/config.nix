{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.lists) optionals;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.binds) mkKeymap;

  cfg = config.vim.session.nvim-session-manager;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins =
        [
          "neovim-session-manager"
          "plenary-nvim"
        ]
        ++ optionals cfg.usePicker ["dressing-nvim"];

      keymaps = [
        (mkKeymap "n" cfg.mappings.loadSession ":SessionManager load_session<CR>" {desc = "Load session";})
        (mkKeymap "n" cfg.mappings.deleteSession ":SessionManager delete_session<CR>" {desc = "Delete session";})
        (mkKeymap "n" cfg.mappings.saveCurrentSession ":SessionManager save_current_session<CR>" {desc = "Save current session";})
        (mkKeymap "n" cfg.mappings.loadLastSession ":SessionManager load_last_session<CR>" {desc = "Load last session";})
      ];

      pluginRC.nvim-session-manager = entryAnywhere ''
        local Path = require('plenary.path')
        local sm = require('session_manager.config')
        require('session_manager').setup(${toLuaObject cfg.setupOpts})
      '';
    };
  };
}
