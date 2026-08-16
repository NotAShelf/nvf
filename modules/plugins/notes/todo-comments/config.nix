{
  config,
  lib,
  options,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.lists) optional;
  inherit (lib.nvim.binds) mkKeymap;

  cfg = config.vim.notes.todo-comments;
  inherit (options.vim.notes.todo-comments) mappings;
in {
  config = mkIf cfg.enable {
    vim.lazy.plugins.todo-comments-nvim = {
      package = "todo-comments-nvim";
      setupModule = "todo-comments";
      inherit (cfg) setupOpts;
      event = [
        {
          event = "User";
          pattern = "LazyFile";
        }
      ];
      cmd = ["TodoQuickFix" "TodoLocList" "TodoTelescope" "TodoFzfLua" "TodoTrouble"];
      keys =
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
    };
  };
}
