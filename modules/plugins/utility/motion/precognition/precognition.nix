{lib, ...}: let
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.types) attrsOf listOf str bool int submodule;
  inherit (lib.nvim.types) mkPluginSetupOption;

  mkHintType = description:
    mkOption {
      inherit description;
      default = {};
      type = attrsOf (submodule {
        options = {
          text = mkOption {
            type = str;
            description = "The easier-to-read depiction of the motion";
          };

          prio = mkOption {
            type = int;
            default = 1;
            description = "The priority of the hint";
            example = 10;
          };
        };
      });
    };
in {
  options.vim.utility.motion.precognition = {
    enable = mkEnableOption "assisted motion discovery[precognition.nvim]";
    setupOpts = mkPluginSetupOption "precognition.nvim" {
      startVisible = mkOption {
        type = bool;
        default = true;
        description = "Whether to start 'precognition' automatically";
      };

      showBlankVirtLine = mkOption {
        type = bool;
        default = true;
        description = "Whether to show a blank virtual line when no movements are shown";
      };

      highlightColor = mkOption {
        type = attrsOf str;
        default = {link = "Comment";};
        example = literalExpression ''
          { link = "Comment"; }
          # or
          { foreground = "#0000FF"; background = "#000000"; };
        '';
        description = "The highlight for the virtual text";
      };

      disabled_fts = mkOption {
        type = listOf str;
        default = ["startify"];
        example = literalExpression ''["startify"]'';
        description = "Filetypes that automatically disable 'precognition'";
      };

      hints = mkHintType "What motions display, and at what priority";
      gutterHints = mkHintType ''
        What motions display and at what priority. Only appears in gutters
      '';
    };
  };
}
