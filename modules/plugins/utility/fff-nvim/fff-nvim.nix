{
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) attrs;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.utility.fff-nvim = {
    enable = mkEnableOption "fff.nvim, a fast file picker for Neovim";

    setupOpts = mkPluginSetupOption "fff.nvim" {
      base_path = mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Base directory for searching files. Defaults to the current working directory.";
      };

      prompt = mkOption {
        type = lib.types.str;
        default = "  ";
        description = "Prompt symbol used by the picker.";
      };

      title = mkOption {
        type = lib.types.str;
        default = "FFF Files";
        description = "Title of the picker window.";
      };

      max_results = mkOption {
        type = lib.types.int;
        default = 100;
        description = "Maximum number of results to display.";
      };

      max_threads = mkOption {
        type = lib.types.int;
        default = 4;
        description = "Maximum number of background threads used for search.";
      };

      layout = mkOption {
        type = attrs;
        default = {};
        description = "Layout settings (height, width, prompt_position, preview_position, ...).";
      };

      preview = mkOption {
        type = attrs;
        default = {};
        description = "Preview settings (enabled, max_size, line_numbers, ...).";
      };

      keymaps = mkOption {
        type = attrs;
        default = {};
        description = "Keymap overrides for the picker.";
      };

      icons = mkOption {
        type = attrs;
        default = {};
        description = "Icon settings (requires a Nerd Font / icon provider).";
      };

      frecency = mkOption {
        type = attrs;
        default = {};
        description = "Frecency database settings.";
      };

      debug = mkOption {
        type = attrs;
        default = {};
        description = "Debug-related settings.";
      };
    };
  };
}
