{lib, ...}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) int bool str nullOr enum;
in {
  options.vim.treesitter.context = {
    enable = mkEnableOption "context of current buffer contents [nvim-treesitter-context] ";

    maxLines = mkOption {
      type = int;
      default = 0;
      description = "How many lines the window should span. Values &lt;=0 mean no limit.";
    };

    minWindowHeight = mkOption {
      type = int;
      default = 0;
      description = "Minimum editor window height to enable context. Values &lt;= 0 mean no limit.";
    };

    lineNumbers = mkOption {
      type = bool;
      default = true;
      description = "";
    };

    multilineThreshold = mkOption {
      type = int;
      default = 20;
      description = "Maximum number of lines to collapse for a single context line.";
    };

    trimScope = mkOption {
      type = enum ["inner" "outer"];
      default = "outer";
      description = "Which context lines to discard if [](#opt-vim.treesitter.context.maxLines) is exceeded.";
    };

    mode = mkOption {
      type = enum ["cursor" "topline"];
      default = "cursor";
      description = "Line used to calculate context.";
    };

    separator = mkOption {
      type = nullOr str;
      default = null;
      description = ''
        Separator between context and content. Should be a single character string, like '-'.

        When separator is set, the context will only show up when there are at least 2 lines above cursorline.
      '';
    };

    zindex = mkOption {
      type = int;
      default = 20;
      description = "The Z-index of the context window.";
    };
  };
}
