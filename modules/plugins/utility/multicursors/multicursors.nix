{lib, ...}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) attrsOf nullOr bool int str submodule;
  inherit (lib.nvim.types) mkPluginSetupOption;

  hintConfig = {
    options = {
      float_opts = mkOption {
        description = "The options for the floating hint window";
        type = submodule {
          options = {
            border = mkOption {
              type = str;
              default = "none";
              description = "The border style for the hint window";
            };
          };
        };
      };

      position = mkOption {
        type = str;
        default = "bottom";
        description = "The position of the hint window";
      };
    };
  };

  generateHints = {
    options = {
      normal = mkOption {
        type = bool;
        default = true;
        description = "Generate hints for the normal mode";
      };

      insert = mkOption {
        type = bool;
        default = true;
        description = "Generate hints for the insert mode";
      };

      extend = mkOption {
        type = bool;
        default = true;
        description = "Generate hints for the extend mode";
      };

      config = mkOption {
        description = "The configuration for generating hints for multicursors.nvim";
        type = submodule {
          options = {
            column_count = mkOption {
              type = nullOr int;
              default = null;
              description = "The number of columns to use for the hint window";
            };

            max_hint_length = mkOption {
              type = int;
              default = 25;
              description = "The maximum length of the hint";
            };
          };
        };

        default = {
          column_count = null;
          max_hint_length = 25;
        };
      };
    };
  };
in {
  options.vim.utility.multicursors = {
    enable = mkEnableOption "vscode like multiple cursors [multicursor.nvim]";

    setupOpts = mkPluginSetupOption "multicursors" {
      DEBUG_MODE = mkOption {
        type = bool;
        default = false;
        description = "Enable debug mode.";
      };

      create_commands = mkOption {
        type = bool;
        default = true;
        description = "Create Multicursor user commands";
      };

      updatetime = mkOption {
        type = int;
        default = 50;
        description = "The time in milliseconds to wait before updating the cursor in insert mode";
      };

      nowait = mkOption {
        type = bool;
        default = true;
        description = "Don't wait for the cursor to move before updating the cursor";
      };

      mode_keys = mkOption {
        type = attrsOf str;
        default = {
          insert = "i";
          append = "a";
          change = "c";
          extend = "e";
        };
        description = "The keys to use for each mode";
      };

      hint_config = mkOption {
        type = submodule hintConfig;
        default = {
          float_opts.border = "none";
          position = "bottom";
        };
        description = "The configuration for the hint window";
      };

      generate_hints = mkOption {
        type = submodule generateHints;
        default = {
          normal = true;
          insert = true;
          extend = true;
          config = {
            column_count = null;
            max_hint_length = 25;
          };
        };
        description = "The configuration for generating hints";
      };
    };
  };
}
