{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.binds) mkBinding;

  cfg = config.vim.notes.todo-comments;
  self = import ./todo-comments.nix {inherit lib;};
  inherit (self.options.vim.notes.todo-comments) mappings;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = [
        "todo-comments"
      ];

      maps.normal = mkMerge [
        (mkBinding cfg.mappings.quickFix ":TodoQuickFix<CR>" mappings.quickFix.description)
        (mkIf config.vim.telescope.enable (mkBinding cfg.mappings.telescope ":TodoTelescope<CR>" mappings.telescope.description))
        (mkIf config.vim.lsp.trouble.enable (mkBinding cfg.mappings.trouble ":TodoTrouble<CR>" mappings.trouble.description))
      ];

      luaConfigRC.todo-comments = ''
        require('todo-comments').setup {
          highlight = {
            before = "", -- "fg" or "bg" or empty
            keyword = "bg", -- "fg", "bg", "wide" or empty
            after = "fg", -- "fg" or "bg" or empty
            pattern = ${cfg.patterns.highlight},
            comments_only = true, -- uses treesitter to match keywords in comments only
            max_line_len = 400, -- ignore lines longer than this
            exclude = {}, -- list of file types to exclude highlighting
          },
          search = {
            command = "${pkgs.ripgrep}/bin/rg",
            args = {
              "--color=never",
              "--no-heading",
              "--with-filename",
              "--line-number",
              "--column",
            },
            pattern = ${cfg.patterns.search},
          },
        }
      '';
    };
  };
}
