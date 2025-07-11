{lib, ...}: let
  inherit
    (lib.types)
    nullOr
    str
    bool
    attrsOf
    ints
    enum
    ;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption luaInline;
in {
  options.vim.assistant.supermaven-nvim = {
    enable = mkEnableOption "Supermaven AI assistant";

    setupOpts = mkPluginSetupOption "Supermaven" {
      keymaps = {
        accept_suggestion = mkOption {
          type = nullOr str;
          default = null;
          example = "<Tab>";
          description = "The key to accept a suggestion";
        };
        clear_suggestion = mkOption {
          type = nullOr str;
          default = null;
          example = "<C-]>";
          description = "The key to clear a suggestion";
        };
        accept_word = mkOption {
          type = nullOr str;
          default = null;
          example = "<C-j>";
          description = "The key to accept a word";
        };
      };
      ignore_file = mkOption {
        type = nullOr (attrsOf bool);
        default = null;
        example = {
          markdown = true;
        };
        description = "List of fileto ignore";
      };
      color = {
        suggestion_color = mkOption {
          type = nullOr str;
          default = null;
          example = "#ffffff";
          description = "The hex color of the suggestion";
        };
        cterm = mkOption {
          type = nullOr ints.u8;
          default = null;
          example = 244;
          description = "The cterm color of the suggestion";
        };
      };
      log_level = mkOption {
        type = nullOr (enum [
          "off"
          "trace"
          "debug"
          "info"
          "warn"
          "error"
        ]);
        default = null;
        example = "info";
        description = "The log level. Set to `\"off\"` to disable completely";
      };
      disable_inline_completion = mkOption {
        type = nullOr bool;
        default = null;
        description = "Disable inline completion for use with cmp";
      };
      disable_keymaps = mkOption {
        type = nullOr bool;
        default = null;
        description = "Disable built-in keymaps for more manual control";
      };
      condition = mkOption {
        type = nullOr luaInline;
        default = null;
        description = ''
          Condition function to check for stopping supermaven.

          A returned `true` means to stop supermaven
        '';
      };
    };
  };
}
