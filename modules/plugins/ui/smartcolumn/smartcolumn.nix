{lib, ...}: let
  inherit (lib.options) mkOption mkEnableOption literalExpression;
  inherit (lib.types) nullOr str attrsOf either listOf;
  inherit (lib.modules) mkRenamedOptionModule;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  imports = let
    renamedSetupOpt = oldPath: newPath:
      mkRenamedOptionModule (["vim" "ui" "smartcolumn"] ++ oldPath) (["vim" "ui" "smartcolumn" "setupOpts"] ++ newPath);
  in [
    (renamedSetupOpt ["disabledFiletypes"] ["disabled_filetypes"])
    (renamedSetupOpt ["showColumnAt"] ["colorcolumn"])
    (renamedSetupOpt ["columnAt" "languages"] ["custom_colorcolumn"])
  ];

  options.vim.ui.smartcolumn = {
    enable = mkEnableOption "line length indicator";

    setupOpts = mkPluginSetupOption "smartcolumn.nvim" {
      colorcolumn = mkOption {
        type = nullOr (either str (listOf str));
        default = "120";
        description = "The position at which the column will be displayed. Set to null to disable";
      };

      disabled_filetypes = mkOption {
        type = listOf str;
        default = ["help" "text" "markdown" "NvimTree" "alpha"];
        description = "The filetypes smartcolumn will be disabled for.";
      };

      custom_colorcolumn = mkOption {
        description = "The position at which smart column should be displayed for each individual buffer type";
        type = attrsOf (either str (listOf str));
        default = {};

        example = literalExpression ''
          vim.ui.smartcolumn.setupOpts.custom_colorcolumn = {
            nix = "110";
            ruby = "120";
            java = "130";
            go = ["90" "130"];
          };
        '';
      };
    };
  };
}
