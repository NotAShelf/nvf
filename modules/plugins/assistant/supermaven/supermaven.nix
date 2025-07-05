{lib, ...}: let
  inherit (lib) mkOption mkEnableOption types;
in {
  options.vim.assistant.supermaven = {
    enable = mkEnableOption "Supermaven AI assistant";

    setupOpts = lib.nvim.types.mkPluginSetupOption "Supermaven" {
      keymaps = {
        accept_suggestion = mkOption {
          type = types.nullOr lib.types.str;
          default = null;
          example = "<Tab>";
          description = "The key to accept a suggestion";
        };
        clear_suggestion = mkOption {
          type = types.nullOr lib.types.str;
          default = null;
          example = "<C-]>";
          description = "The key to clear a suggestion";
        };
        accept_word = mkOption {
          type = types.nullOr lib.types.str;
          default = null;
          example = "<C-j>";
          description = "The key to accept a word";
        };
      };
      ignore_filetypes = mkOption {
        type = types.nullOr (types.attrsOf types.bool);
        default = null;
        example = {
          markdown = true;
        };
        description = "List of filetypes to ignore";
      };
      color = {
        suggestion_color = mkOption {
          type = types.nullOr types.str;
          default = null;
          example = "#ffffff";
          description = "The hex color of the suggestion";
        };
        cterm = mkOption {
          type = types.nullOr types.ints.u8;
          default = null;
          example = 244;
          description = "The cterm color of the suggestion";
        };
      };
      log_level = mkOption {
        type = types.nullOr (
          types.enum [
            "off"
            "trace"
            "debug"
            "info"
            "warn"
            "error"
          ]
        );
        default = null;
        example = "info";
        description = "The log level. Set to `\"off\"` to disable completely";
      };
      disable_inline_completion = mkOption {
        type = types.nullOr types.bool;
        default = null;
        description = "Disable inline completion for use with cmp";
      };
      disable_keymaps = mkOption {
        type = types.nullOr types.bool;
        default = null;
        description = "Disable built-in keymaps for more manual control";
      };
      condition = mkOption {
        type = types.nullOr lib.nvim.types.luaInline;
        default = null;
        description = "Condition function to check for stopping supermaven. A returned `true` means to stop supermaven";
      };
    };
  };
}
