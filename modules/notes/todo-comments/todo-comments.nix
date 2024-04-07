{
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types mkMappingOption mkRenamedOptionModule;
in {
  imports = let
    renamedSetupOption = oldPath: newPath:
      mkRenamedOptionModule
      (["vim" "notes" "todo-comments"] ++ oldPath)
      (["vim" "notes" "todo-comments" "setupOpts"] ++ newPath);
  in [
    (renamedSetupOption ["patterns" "highlight"] ["highlight" "pattern"])
    (renamedSetupOption ["patterns" "search"] ["search" "pattern"])
  ];

  options.vim.notes.todo-comments = {
    enable = mkEnableOption "todo-comments: highlight and search for todo comments like TODO, HACK, BUG in your code base";

    setupOpts = lib.nvim.types.mkPluginSetupOption "todo-comments.nvim" {
      highlight = {
        pattern = mkOption {
          type = types.str;
          default = ''.*<(KEYWORDS)(\([^\)]*\))?:'';
          description = "vim regex pattern used for highlighting comments";
        };
      };

      search = {
        pattern = mkOption {
          type = types.str;
          default = ''\b(KEYWORDS)(\([^\)]*\))?:'';
          description = "ripgrep regex pattern used for searching comments";
        };

        command = mkOption {
          type = types.str;
          default = "${pkgs.ripgrep}/bin/rg";
          description = "search command";
        };

        args = mkOption {
          type = types.listOf types.str;
          default = ["--color=never" "--no-heading" "--with-filename" "--line-number" "--column"];
          description = "arguments to pass to the search command";
        };
      };
    };

    mappings = {
      quickFix = mkMappingOption "Open Todo-s in a quickfix list" "<leader>tdq";
      telescope = mkMappingOption "Open Todo-s in telescope" "<leader>tds";
      trouble = mkMappingOption "Open Todo-s in Trouble" "<leader>tdt";
    };
  };
}
