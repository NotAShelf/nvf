{
  config,
  lib,
  options,
  ...
}: let
  inherit (lib.modules) mkMerge mkIf;
  inherit (lib.nvim.binds) mkBinding;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.notes.todo-comments;
  inherit (options.vim.notes.todo-comments) mappings;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = [
        "todo-comments-nvim"
      ];

      maps.normal = mkMerge [
        (mkBinding cfg.mappings.quickFix ":TodoQuickFix<CR>" mappings.quickFix.description)
        (mkIf config.vim.telescope.enable (mkBinding cfg.mappings.telescope ":TodoTelescope<CR>" mappings.telescope.description))
        (mkIf config.vim.lsp.trouble.enable (mkBinding cfg.mappings.trouble ":TodoTrouble<CR>" mappings.trouble.description))
      ];

      pluginRC.todo-comments = ''
        require('todo-comments').setup(${toLuaObject cfg.setupOpts})
      '';
    };
  };
}
