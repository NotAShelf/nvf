{lib, ...}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) int bool str nullOr enum;
  inherit (lib.nvim.types) mkPluginSetupOption;
  inherit (lib.nvim.config) batchRenameOptions;
  migrationTable = {
    maxLines = "max_lines";
    minWindowHeight = "min_window_height";
    lineNumbers = "line_numbers";
    multilineThreshold = "multiline_threshold";
    trimScope = "trim_scope";
    mode = "mode";
    separator = "separator";
    zindex = "z_index";
  };

  renamedSetupOpts =
    batchRenameOptions
    ["vim" "treesitter" "context"]
    ["vim" "treesitter" "context" "setupOpts"]
    migrationTable;
in {
  imports = renamedSetupOpts;
  options.vim.treesitter.context = {
    enable = mkEnableOption "context of current buffer contents [nvim-treesitter-context] ";

    setupOpts = mkPluginSetupOption "treesitter-context" {
      max_lines = mkOption {
        type = int;
        default = 0;
        description = ''
          How many lines the window should span.

          Values >= 0 mean there will be no limit.
        '';
      };

      min_window_height = mkOption {
        type = int;
        default = 0;
        description = ''
          Minimum editor window height to enable context.

          Values >= 0 mean there will be no limit.
        '';
      };

      line_numbers = mkOption {
        type = bool;
        default = true;
        description = "Whether to display line numbers in current context";
      };

      multiline_threshold = mkOption {
        type = int;
        default = 20;
        description = "Maximum number of lines to collapse for a single context line.";
      };

      trim_scope = mkOption {
        type = enum ["inner" "outer"];
        default = "outer";
        description = ''
          Which context lines to discard if
          {option}`vim.treesitter.context.setupOpts.max_lines` is exceeded.
        '';
      };

      mode = mkOption {
        type = enum ["cursor" "topline"];
        default = "cursor";
        description = "Line used to calculate context.";
      };

      separator = mkOption {
        type = nullOr str;
        default = "-";
        description = ''
          Separator between context and content. This option should
          be a single character string, like '-'.

          When separator is set, the context will only show up when
          there are at least 2 lines above cursorline.
        '';
      };

      zindex = mkOption {
        type = int;
        default = 20;
        description = "The Z-index of the context window.";
      };
    };
  };
}
