{
  pkgs,
  lib,
  ...
}: let
  inherit (lib.modules) mkRenamedOptionModule;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) str listOf;
  inherit (lib.nvim.binds) mkMappingOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
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

    setupOpts = mkPluginSetupOption "todo-comments.nvim" {
      highlight = {
        pattern = mkOption {
          type = str;
          default = ''.*<(KEYWORDS)(\([^\)]*\))?:'';
          description = "vim regex pattern used for highlighting comments";
        };
      };

      search = {
        pattern = mkOption {
          type = str;
          default = ''\b(KEYWORDS)(\([^\)]*\))?:'';
          description = "ripgrep regex pattern used for searching comments";
        };

        command = mkOption {
          type = str;
          default = "${pkgs.ripgrep}/bin/rg";
          description = "search command";
        };

        args = mkOption {
          type = listOf str;
          default = ["--color=never" "--no-heading" "--with-filename" "--line-number" "--column"];
          description = "arguments to pass to the search command";
        };
      };
    };

    mappings = {
      quickFix = mkMappingOption config.vim.enableNvfKeymaps "Open Todo-s in a quickfix list" "<leader>tdq";
      telescope = mkMappingOption config.vim.enableNvfKeymaps "Open Todo-s in telescope" "<leader>tds";
      trouble = mkMappingOption config.vim.enableNvfKeymaps "Open Todo-s in Trouble" "<leader>tdt";
    };
  };
}
