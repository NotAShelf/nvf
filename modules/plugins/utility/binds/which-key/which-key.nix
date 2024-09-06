{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) attrsOf nullOr str attrs enum bool;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.binds.whichKey = {
    enable = mkEnableOption "which-key keybind helper menu";

    register = mkOption {
      description = "Register label for which-key keybind helper menu";
      type = attrsOf (nullOr str);
      default = {};
    };

    setupOpts = mkPluginSetupOption "which-key" {
      preset = mkOption {
        type = enum ["classic" "modern" "helix"];
        default = "modern";
        description = "The default preset for the which-key window";
      };

      notify = mkOption {
        type = bool;
        default = false; # FIXME: this should be true before the merge
        description = "Show a warning when issues were detected with mappings";
      };

      replace = mkOption {
        type = attrs;
        default = {
          "<space>" = "SPACE";
          "<leader>" = "SPACE";
          "<cr>" = "RETURN";
          "<tab>" = "TAB";
        };
        description = "Functions/Lua Patterns for formatting the labels";
      };

      win = {
        border = mkOption {
          type = str;
          default = config.vim.ui.borders.plugins.which-key.style;
          description = "Which-key window border style";
        };
      };
    };
  };
}
