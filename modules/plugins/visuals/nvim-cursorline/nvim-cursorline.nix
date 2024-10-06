{lib, ...}: let
  inherit (lib.modules) mkRenamedOptionModule mkRemovedOptionModule;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) int bool;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  imports = [
    (mkRenamedOptionModule ["vim" "visuals" "cursorline" "lineTimeout"] ["vim" "visuals" "cursorline" "setupOpts" "line_timeout"])
    (mkRemovedOptionModule ["vim" "visuals" "cursorline" "lineNumbersOnly"] ''
      `vim.visuals.cursorline.lineNumbersOnly` has been removed. Use `vim.visuals.cursorline.number` instead.
    '')
  ];

  options.vim.visuals.cursorline = {
    enable = mkEnableOption "cursor word and line highlighting [nvim-cursorline]";
    setupOpts = mkPluginSetupOption "cursorline" {
      cursorline = {
        enable = mkEnableOption "cursor line highlighting";
        timeout = mkOption {
          type = int;
          default = 1000;
        };

        number = mkOption {
          type = bool;
          default = false;
        };
      };

      cursorword = {
        enable = mkEnableOption "cursor word highlighting";
        timeout = mkOption {
          type = int;
          default = 1000;
        };

        min_length = mkOption {
          type = int;
          default = 3;
        };

        hl.underline = mkOption {
          type = bool;
          default = true;
        };
      };
    };
  };
}
