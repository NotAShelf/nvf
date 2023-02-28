{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.visuals;
in {
  options.vim.visuals = {
    enable = mkOption {
      type = types.bool;
      description = "visual enhancements";
      default = false;
    };

    nvimWebDevicons.enable = mkOption {
      type = types.bool;
      description = "enable dev icons. required for certain plugins [nvim-web-devicons]";
      default = false;
    };

    lspkind.enable = mkOption {
      type = types.bool;
      description = "enable vscode-like pictograms for lsp [lspkind]";
      default = false;
    };

    scrollBar.enable = mkOption {
      type = types.bool;
      description = "enable scrollbar [scrollbar.nvim]";
      default = false;
    };

    smoothScroll.enable = mkOption {
      type = types.bool;
      description = "enable smooth scrolling [cinnamon-nvim]";
      default = false;
    };

    cellularAutomaton.enable = mkOption {
      type = types.bool;
      description = "enable cellular automaton [cellular-automaton]";
      default = false;
    };

    cursorWordline = {
      enable = mkOption {
        type = types.bool;
        description = "enable word and delayed line highlight [nvim-cursorline]";
        default = false;
      };

      lineTimeout = mkOption {
        type = types.int;
        description = "time in milliseconds for cursorline to appear";
      };
    };

    indentBlankline = {
      enable = mkOption {
        type = types.bool;
        description = "enable indentation guides [indent-blankline]";
        default = false;
      };

      listChar = mkOption {
        type = types.str;
        description = "Character for indentation line";
        default = "│";
      };

      fillChar = mkOption {
        type = types.str;
        description = "Character to fill indents";
        default = "⋅";
      };

      eolChar = mkOption {
        type = types.str;
        description = "Character at end of line";
        default = "↴";
      };

      showCurrContext = mkOption {
        type = types.bool;
        description = "Highlight current context from treesitter";
        default = true;
      };
    };
  };
}
