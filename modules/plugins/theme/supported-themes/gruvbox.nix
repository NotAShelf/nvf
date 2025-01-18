{
  config,
  lib,
  ...
}: let
  inherit (lib.attrsets) genAttrs mergeAttrsList;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) bool str;
  inherit (lib.nvim.types) mkPluginSetupOption;
  cfg = config.vim.theme;

  mkEnableOption' = name: mkEnableOption name // {default = true;};
in {
  gruvbox = {
    setupOpts =
      mkPluginSetupOption "gruvbox" {
        transparent_mode = mkOption {
          type = bool;
          default = cfg.transparent;
          internal = true;
        };
        italic =
          {
            operators = mkEnableOption "operators";
          }
          // genAttrs [
            "strings"
            "emphasis"
            "comments"
            "folds"
          ] (name: mkEnableOption' name);

        contrast = mkOption {
          type = str;
          default = "";
        };
        # TODO: fix these
        # palette_overrides = mkLuaInline "{}";
        # overrides = mkLuaInline "{}";
      }
      // mergeAttrsList [
        (genAttrs [
          "terminal_colors"
          "undercurls"
          "underline"
          "bold"
          "strikethrough"
          "inverse"
        ] (name: mkEnableOption' name))
        (genAttrs [
          "invert_selection"
          "invert_signs"
          "invert_tabline"
          "invert_intend_guides"
          "dim_inactive"
        ] (name: mkEnableOption name))
      ];
    setup = ''
      -- Gruvbox theme
      vim.o.background = "${cfg.style}"
      vim.cmd("colorscheme gruvbox")
    '';
    styles = ["dark" "light"];
  };
}
