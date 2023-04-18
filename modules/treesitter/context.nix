{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  treesitter = config.vim.treesitter;
  cfg = treesitter.context;
in {
  options.vim.treesitter.context = {
    enable = mkEnableOption "context of current buffer contents [nvim-treesitter-context] ";

    maxLines = mkOption {
      description = "How many lines the window should span. Values &lt;=0 mean no limit.";
      type = types.int;
      default = 0;
    };

    minWindowHeight = mkOption {
      description = "Minimum editor window height to enable context. Values &lt;= 0 mean no limit.";
      type = types.int;
      default = 0;
    };

    lineNumbers = mkOption {
      description = "";
      type = types.bool;
      default = true;
    };

    multilineThreshold = mkOption {
      description = "Maximum number of lines to collapse for a single context line.";
      type = types.int;
      default = 20;
    };

    trimScope = mkOption {
      description = nvim.nmd.asciiDoc "Which context lines to discard if <<opt-vim.treesitter.context.maxLines>> is exceeded.";
      type = types.enum ["inner" "outer"];
      default = "outer";
    };

    mode = mkOption {
      description = "Line used to calculate context.";
      type = types.enum ["cursor" "topline"];
      default = "cursor";
    };

    separator = mkOption {
      description = nvim.nmd.asciiDoc ''
        Separator between context and content. Should be a single character string, like '-'.

        When separator is set, the context will only show up when there are at least 2 lines above cursorline.
      '';
      type = with types; nullOr str;
      default = null;
    };

    zindex = mkOption {
      description = "The Z-index of the context window.";
      type = types.int;
      default = 20;
    };
  };

  config = mkIf (treesitter.enable && cfg.enable) {
    vim.startPlugins = ["nvim-treesitter-context"];

    vim.luaConfigRC.treesitter-context = nvim.dag.entryAnywhere ''
      require'treesitter-context'.setup {
        enable = true,
        max_lines = ${toString cfg.maxLines},
        min_window_height = ${toString cfg.minWindowHeight},
        line_numbers = ${boolToString cfg.lineNumbers},
        multiline_threshold = ${toString cfg.multilineThreshold},
        trim_scope = '${cfg.trimScope}',
        mode = '${cfg.mode}',
        separator = ${nvim.lua.nullString cfg.separator},
        max_lines = ${toString cfg.zindex},
      }
    '';
  };
}
