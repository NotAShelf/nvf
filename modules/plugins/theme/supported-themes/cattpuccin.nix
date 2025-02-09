{
  config,
  lib,
  ...
}: let
  inherit (lib.attrsets) genAttrs;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) bool str;
  inherit (lib.nvim.types) mkPluginSetupOption;
  cfg = config.vim.theme;

  mkEnableOption' = name: mkEnableOption name // {default = true;};
in {
  catppuccin = {
    setupOpts = mkPluginSetupOption "catppuccin" {
      flavour = mkOption {
        type = str;
        default = cfg.style;
        # internal = true;
      };
      transparent_background = mkOption {
        type = bool;
        default = cfg.transparent;
        internal = true;
      };
      term_colors = mkEnableOption' "term_colors";
      integrations =
        {
          nvimtree = {
            enabled = mkEnableOption' "enabled";
            transparent_panel = mkOption {
              type = bool;
              default = cfg.transparent;
            };
            show_root = mkEnableOption' "show_root";
          };

          navic = {
            enabled = mkEnableOption' "enabled";
            # lualine will set backgound to mantle
            custom_bg = mkOption {
              type = str;
              default = "NONE";
            };
          };
        }
        // genAttrs [
          "hop"
          "gitsigns"
          "telescope"
          "treesitter"
          "treesitter_context"
          "ts_rainbow"
          "fidget"
          "alpha"
          "leap"
          "markdown"
          "noice"
          "notify"
          "which_key"
        ] (name: mkEnableOption' name);
    };
    setup = ''
      -- Catppuccin theme
      -- setup must be called before loading
      vim.cmd.colorscheme "catppuccin"
    '';
    styles = ["mocha" "latte" "frappe" "macchiato"];
  };
}
