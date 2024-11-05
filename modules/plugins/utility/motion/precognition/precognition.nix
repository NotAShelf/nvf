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
            description = "The easier-to-read depiction of the motion.";
          };
          prio = mkOption {
            type = int;
            description = "The priority of the hint.";
            example = 10;
            default = 1;
          };
        };
      });
    };
in {
  options.vim.utility.motion.precognition = {
    enable = mkEnableOption "precognition.nvim plugin";

    setupOpts = mkPluginSetupOption "precognition.nvim" {
      startVisible = mkOption {
        type = bool;
        description = "Whether to start 'precognition' automatically.";
        default = true;
      };

      showBlankVirtLine = mkOption {
        type = bool;
        description = "Whether to show a blank virtual line when no movements are shown.";
        default = true;
      };

      highlightColor = mkOption {
        type = attrsOf str;
        default = {link = "Comment";};
        example = literalExpression ''
          { link = "Comment"; }
          # or
          { foreground = "#0000FF"; background = "#000000"; };
        '';
        description = ''
          The highlight for the virtual text.
        '';
      };

      hints = mkHintType "What motions display and at what priority.";

      gutterHints =
        mkHintType "What motions display and at what priority. Only appears in gutters.";

      disabled_fts = mkOption {
        type = listOf str;
        default = ["startify"];
        example = literalExpression ''["startify"]'';
      };
    };
  };
}
