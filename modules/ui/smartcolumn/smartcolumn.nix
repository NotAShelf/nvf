{lib, ...}: let
  inherit (lib) mkEnableOption mkOption types literalExpression;
in {
  options.vim.ui.smartcolumn = {
    enable = mkEnableOption "line length indicator";

    showColumnAt = mkOption {
      type = types.nullOr types.int;
      default = 120;
      description = "The position at which the column will be displayed. Set to null to disable";
    };

    disabledFiletypes = mkOption {
      type = types.listOf types.str;
      default = ["help" "text" "markdown" "NvimTree" "alpha"];
      description = "The filetypes smartcolumn will be disabled for.";
    };

    columnAt = {
      languages = mkOption {
        description = "The position at which smart column should be displayed for each individual buffer type";
        type = types.submodule {
          freeformType = with types; attrsOf (either int (listOf int));
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
