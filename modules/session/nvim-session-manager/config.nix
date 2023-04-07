{
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.session.nvim-session-manager;
in {
  config = mkIf cfg.enable {
    vim.startPlugins =
      [
        "nvim-session-manager"
        "plenary-nvim"
      ]
      ++ optionals (cfg.usePicker) ["dressing-nvim"];

    vim.luaConfigRC.nvim-session-manager = nvim.dag.entryAnywhere ''
      local Path = require('plenary.path')
      local sm = require('session_manager.config')
      require('session_manager').setup({
        sessions_dir = Path:new(vim.fn.stdpath('data'), 'sessions'),

        path_replacer = '${toString cfg.pathReplacer}',

        colon_replacer = '${toString cfg.colonReplacer}',

        autoload_mode = sm.AutoloadMode.${toString cfg.autoloadMode},

        autosave_last_session = ${boolToString cfg.autoSave.lastSession},

        autosave_ignore_not_normal = ${boolToString cfg.autoSave.ignoreNotNormal},

        autosave_ignore_dirs = {${concatStringsSep ", " (map (x: "\'" + x + "\'") cfg.autoSave.ignoreDirs)}},

        autosave_ignore_filetypes = {${concatStringsSep ", " (map (x: "\'" + x + "\'") cfg.autoSave.ignoreFiletypes)}},

        autosave_ignore_buftypes = {${concatStringsSep ", " (map (x: "\'" + x + "\'") cfg.autoSave.ignoreBufTypes)}},

        autosave_only_in_session = ${boolToString cfg.autoSave.onlyInSession},
        max_path_length = ${toString cfg.maxPathLength},
      })
    '';
  };
}
