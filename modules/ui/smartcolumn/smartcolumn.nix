{lib, ...}: let
  inherit (lib.options) mkOption mkEnableOption literalExpression;
  inherit (lib.types) nullOr int str submodule attrsOf either listOf;
in {
  options.vim.ui.smartcolumn = {
    enable = mkEnableOption "line length indicator";

    showColumnAt = mkOption {
      type = nullOr int;
      default = 120;
      description = "The position at which the column will be displayed. Set to null to disable";
    };

    disabledFiletypes = mkOption {
      type = listOf str;
      default = ["help" "text" "markdown" "NvimTree" "alpha"];
      description = "The filetypes smartcolumn will be disabled for.";
    };

    columnAt = {
      languages = mkOption {
        description = "The position at which smart column should be displayed for each individual buffer type";
        type = submodule {
          freeformType = attrsOf (either int (listOf int));
        };

        example = literalExpression ''
          vim.ui.smartcolumn.columnAt.languages = {
            nix = 110;
            ruby = 120;
            java = 130;
            go = [90 130];
          };
        '';
      };
    };
  };
}
