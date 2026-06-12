{
  config,
  lib,
  options,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.lists) optional;
  inherit (lib.nvim.binds) mkKeymap;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.notes.todo-comments;
  inherit (options.vim.notes.todo-comments) mappings;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = [
        "todo-comments-nvim"
      ];

      keymaps =
        [
          (mkKeymap "n" cfg.mappings.quickFix ":TodoQuickFix<CR>" {desc = mappings.quickFix.description;})
        ]
        ++ (
          optional config.vim.telescope.enable
          (mkKeymap "n" cfg.mappings.telescope ":TodoTelescope<CR>" {desc = mappings.telescope.description;})
        )
        ++ (
          optional config.vim.lsp.trouble.enable
          (mkKeymap "n" cfg.mappings.trouble ":TodoTrouble<CR>" {desc = mappings.trouble.description;})
        );

      pluginRC.todo-comments = ''
        require('todo-comments').setup(${toLuaObject cfg.setupOpts})
      '';
    };
  };
}
