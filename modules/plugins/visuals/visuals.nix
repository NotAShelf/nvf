{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkRemovedOptionModule mkRenamedOptionModule;
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.types) int bool str nullOr;
  inherit (lib.nvim.binds) mkMappingOption;

  cfg = config.vim.visuals;
in {
  imports = [
    (mkRenamedOptionModule ["vim" "visuals" "indentBlankline" "showCurrContext"] ["vim" "visuals" "indentBlankline" "scope" "enabled"])
    (mkRenamedOptionModule ["vim" "visuals" "indentBlankline" "showEndOfLine"] ["vim" "visuals" "indentBlankline" "scope" "showEndOfLine"])
    (mkRemovedOptionModule ["vim" "visuals" "indentBlankline" "useTreesitter"] "`vim.visuals.indentBlankline.useTreesitter` has been removed upstream and can safely be removed from your configuration.")
  ];

  options.vim.visuals = {
    enable = mkEnableOption "Visual enhancements.";

    nvimWebDevicons.enable = mkEnableOption "dev icons. Required for certain plugins [nvim-web-devicons].";

    scrollBar.enable = mkEnableOption "scrollbar [scrollbar.nvim]";

    smoothScroll.enable = mkEnableOption "smooth scrolling [cinnamon-nvim]";

    cellularAutomaton = {
      enable = mkEnableOption "cellular automaton [cellular-automaton]";

      mappings = {
        makeItRain = mkMappingOption "Make it rain [cellular-automaton]" "<leader>fml";
      };
    };

    cursorline = {
      enable = mkEnableOption "line hightlighting on the cursor [nvim-cursorline]";

      lineTimeout = mkOption {
        type = int;
        description = "Time in milliseconds for cursorline to appear";
        default = 0;
      };

      lineNumbersOnly = mkOption {
        type = bool;
        description = "Hightlight only in the presence of line numbers";
        default = true;
      };
    };

    indentBlankline = {
      enable = mkEnableOption "indentation guides [indent-blankline]";
      debounce = mkOption {
        type = int;
        description = "Debounce time in milliseconds";
        default = 200;
      };

      viewportBuffer = {
        min = mkOption {
          type = int;
          description = "Number of lines above and below of what is currently
            visible in the window";
          default = 30;
        };

        max = mkOption {
          type = int;
          description = "Number of lines above and below of what is currently
            visible in the window";
          default = 500;
        };
      };

      indent = {
        char = mkOption {
          type = str;
          description = "Character for indentation line";
          default = "│";
        };
      };

      listChar = mkOption {
        type = str;
        description = "Character for indentation line";
        default = "│";
      };

      fillChar = mkOption {
        description = "Character to fill indents";
        type = nullOr str;
        default = "⋅";
      };

      eolChar = mkOption {
        description = "Character at end of line";
        type = nullOr str;
        default = "↴";
      };

      scope = {
        enabled = mkOption {
          description = "Highlight current scope from treesitter";
          type = bool;
          default = config.vim.treesitter.enable;
          defaultText = literalExpression "config.vim.treesitter.enable";
        };

        showEndOfLine = mkOption {
          description = ''
            Displays the end of line character set by [](#opt-vim.visuals.indentBlankline.eolChar) instead of the
            indent guide on line returns.
          '';
          type = bool;
          default = cfg.indentBlankline.eolChar != null;
          defaultText = literalExpression "config.vim.visuals.indentBlankline.eolChar != null";
        };
      };
    };

    highlight-undo = {
      enable = mkEnableOption "highlight undo [highlight-undo]";

      highlightForCount = mkOption {
        type = bool;
        default = true;
        description = ''
          Enable support for highlighting when a <count> is provided before the key
          If set to false it will only highlight when the mapping is not prefixed with a <count>
        '';
      };

      duration = mkOption {
        type = int;
        description = "Duration of highlight";
        default = 500;
      };

      undo = {
        hlGroup = mkOption {
          type = str;
          description = "Highlight group for undo";
          default = "HighlightUndo";
        };
      };

      redo = {
        hlGroup = mkOption {
          type = str;
          description = "Highlight group for redo";
          default = "HighlightUndo";
        };
      };
    };
  };
}
