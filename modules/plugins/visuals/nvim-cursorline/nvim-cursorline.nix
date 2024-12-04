{lib, ...}: let
  inherit (lib.modules) mkRenamedOptionModule mkRemovedOptionModule;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) int bool;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  imports = [
    (mkRenamedOptionModule ["vim" "visuals" "cursorline"] ["vim" "visuals" "nvim-cursorline"])
    (mkRenamedOptionModule ["vim" "visuals" "nvim-cursorline" "lineTimeout"] ["vim" "visuals" "nvim-cursorline" "setupOpts" "line_timeout"])
    (mkRemovedOptionModule ["vim" "visuals" "nvim-cursorline" "lineNumbersOnly"] ''
      `vim.visuals.nvim-cursorline.lineNumbersOnly` has been removed. Use `vim.visuals.nvim-cursorline.number` instead.
    '')
  ];

  options.vim.visuals.nvim-cursorline = {
    enable = mkEnableOption "cursor word and line highlighting [nvim-cursorline]";

    # Upstream has **zero** documentation whatsoever. I'm making wild assumptions
    # on what goes into description based don the source code. I'm sorry. Not.
    setupOpts = mkPluginSetupOption "nvim-cursorline" {
      cursorline = {
        enable = mkEnableOption "cursor line highlighting";
        timeout = mkOption {
          type = int;
          default = 1000;
          description = "Cursorline timeout";
        };

        number = mkOption {
          type = bool;
          default = false;
          description = ''
            If true, `vim.wo.cursorlineopt` will be set to "number"
            when the trigger conditions are met.
          '';
        };
      };

      cursorword = {
        enable = mkEnableOption "cursor word highlighting";
        timeout = mkOption {
          type = int;
          default = 1000;
          description = "Cursorword timeout";
        };

        min_length = mkOption {
          type = int;
          default = 3;
          description = ''
            The min_length option defines the minimum number of characters
            a word must have to be highlighted as a "cursor word." Any word
            shorter than this value will be ignored and not highlighted.
          '';
        };

        hl.underline = mkOption {
          type = bool;
          default = true;
          description = "Whether to underline matching cursorword";
        };
      };
    };
  };
}
