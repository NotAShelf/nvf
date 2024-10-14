{lib, ...}: let
  inherit (lib.modules) mkRemovedOptionModule;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) int;
  inherit (lib.nvim.types) mkPluginSetupOption;

  checkDocsMsg = ''
    highlight-undo.nvim has deprecated previously used configuration options in
    a recent update, so previous values will no longer work as expected.

    Please use `vim.visuals.highlight-undo.setupOpts` with upstream instructions
  '';
in {
  imports = [
    # This gives a lot of error messages for those with default values set or modified. Could
    # there be a better way to handle his? Perhaps an assertion?
    (mkRemovedOptionModule ["vim" "visuals" "highlight-undo" "highlightForCount"] checkDocsMsg)
    (mkRemovedOptionModule ["vim" "visuals" "highlight-undo" "undo" "hlGroup"] checkDocsMsg)
    (mkRemovedOptionModule ["vim" "visuals" "highlight-undo" "redo" "hlGroup"] checkDocsMsg)
  ];

  options.vim.visuals.highlight-undo = {
    enable = mkEnableOption "highlight undo [highlight-undo]";
    setupOpts = mkPluginSetupOption "highlight-undo" {
      duration = mkOption {
        type = int;
        default = 500;
        description = "Duration of the highlight";
      };
    };
  };
}
