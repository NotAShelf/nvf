{ lib, ... }:
let
  inherit (lib.types) bool int str;
  inherit (lib.nvim.types) mkPluginSetupOption;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.nvim.binds) mkMappingOption;
  hintConfig = { lib, ... }: {
    options = {
      float_opts = mkOption {
        type = lib.types.submodule {
          options = {
            border = mkOption {
              type = lib.types.str;
              default = "none";
              description = "The border style for the hint window";
            };
          };
        };
      };
      position = mkOption {
        type = lib.types.str;
        default = "bottom";
        description = "The position of the hint window";
      };
    };
  };
  generateHints = { lib, ... }: {
    options = {
      normal = mkOption {
        type = lib.types.bool;
        default = true;
      };
      insert = mkOption {
        type = lib.types.bool;
        default = true;
      };
      extend = mkOption {
        type = lib.types.bool;
        default = true;
      };
      config = mkOption {
        type = lib.types.submodule {
          options = {
            column_count = mkOption {
              type = lib.types.nullOr int;
              description = "The number of columns to use for the hint window";
              default = null;
            };
            max_hint_length = mkOption {
              type = int;
              description = "The maximum length of the hint";
              default = 25;
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
in
{
  options.vim.utility.multicursors = {
    enable = mkEnableOption "multicursors.nvim plugin (vscode like multiple cursors)";

    setupOpts = mkPluginSetupOption "multicursors" {
      DEBUG_MODE = mkOption {
        type = bool;
        default = false;
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
      };
      mode_keys = mkOption {
        type = lib.types.attrsOf str;
        description = "The keys to use for each mode";
        default = {
          insert = "i";
          append = "a";
          change = "c";
          extend = "e";
        };
      };
      hint_config = mkOption {
        type = lib.types.submodule hintConfig;
        description = "The configuration for the hint window";
        default = {
          float_opts = {
            border = "none";
          };
          position = "bottom";
        };
      };
      generate_hints = mkOption {
        type = lib.types.submodule generateHints;
        description = "The configuration for generating hints";
        default = {
          normal = true;
          insert = true;
          extend = true;
          config = {
            column_count = null;
            max_hint_length = 25;
          };
        };
      };
    };
  };
}
