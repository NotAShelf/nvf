{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkMerge mkBinding mkIf;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.notes.todo-comments;
  self = import ./todo-comments.nix {inherit pkgs lib;};
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
        require('todo-comments').setup(${toLuaObject cfg.setupOpts})
      '';
    };
  };
}
