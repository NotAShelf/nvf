{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf nvim boolToString concatStringsSep;

  cfg = config.vim.projects.project-nvim;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = [
      "project-nvim"
    ];

    vim.luaConfigRC.project-nvim = nvim.dag.entryAnywhere ''
      require('project_nvim').setup({
        manual_mode = ${boolToString cfg.manualMode},
        detection_methods = { ${concatStringsSep ", " (map (x: "\"" + x + "\"") cfg.detectionMethods)} },

        -- All the patterns used to detect root dir, when **"pattern"** is in
        -- detection_methods
        patterns = { ${concatStringsSep ", " (map (x: "\"" + x + "\"") cfg.patterns)} },

        -- Table of lsp clients to ignore by name
        -- eg: { "efm", ... }
        ignore_lsp = { ${concatStringsSep ", " (map (x: "\"" + x + "\"") cfg.lspIgnored)} },

        -- Don't calculate root dir on specific directories
        -- Ex: { "~/.cargo/*", ... }
        exclude_dirs = { ${concatStringsSep ", " (map (x: "\"" + x + "\"") cfg.excludeDirs)} },

        -- Show hidden files in telescope
        show_hidden = ${boolToString cfg.showHidden},

        -- When set to false, you will get a message when project.nvim changes your
        -- directory.
        silent_chdir = ${boolToString cfg.silentChdir},

        -- What scope to change the directory, valid options are
        -- * global (default)
        -- * tab
        -- * win
        scope_chdir = '${toString cfg.scopeChdir}',

        -- Path where project.nvim will store the project history for use in
        -- telescope
        datapath = vim.fn.stdpath("data"),
      })
    '';
  };
}
