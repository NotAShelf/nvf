{
  config,
  lib,
  ...
}:
with lib;
with builtins; {
  options.vim.visuals = {
    enable = mkOption {
      type = types.bool;
      description = "Enable visual enhancements";
      default = false;
    };

    nvimWebDevicons.enable = mkOption {
      type = types.bool;
      description = "Enable dev icons. required for certain plugins [nvim-web-devicons]";
      default = false;
    };

    lspkind.enable = mkOption {
      type = types.bool;
      description = "Enable vscode-like pictograms for lsp [lspkind]";
      default = false;
    };

    scrollBar.enable = mkOption {
      type = types.bool;
      description = "Enable scrollbar [scrollbar.nvim]";
      default = false;
    };

    smoothScroll.enable = mkOption {
      type = types.bool;
      description = "Enable smooth scrolling [cinnamon-nvim]";
      default = false;
    };

    cellularAutomaton = {
      enable = mkOption {
        type = types.bool;
        description = "Enable cellular automaton [cellular-automaton]";
        default = false;
      };

      mappings = {
        makeItRain = mkMappingOption "Make it rain [cellular-automaton]" "<leader>fml";
      };
    };

    fidget-nvim = {
      enable = mkOption {
        type = types.bool;
        description = "Enable nvim LSP UI element [fidget-nvim]";
        default = false;
      };
      align = {
        bottom = mkOption {
          type = types.bool;
          description = "Align to bottom";
          default = true;
        };

        right = mkOption {
          type = types.bool;
          description = "Align to right";
          default = true;
        };
      };
    };

    cursorWordline = {
      enable = mkOption {
        type = types.bool;
        description = "Enable word and delayed line highlight [nvim-cursorline]";
        default = false;
      };

      lineTimeout = mkOption {
        type = types.int;
        description = "Time in milliseconds for cursorline to appear";
      };
    };

    indentBlankline = {
      enable = mkOption {
        type = types.bool;
        description = "Enable indentation guides [indent-blankline]";
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
