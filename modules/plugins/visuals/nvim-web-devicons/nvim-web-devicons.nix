{lib, ...}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) nullOr attrsOf attrs enum;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.visuals.nvim-web-devicons = {
    enable = mkEnableOption "Neovim dev icons [nvim-web-devicons]";

    setupOpts = mkPluginSetupOption "nvim-web-devicons" {
      color_icons = mkEnableOption "different highlight colors per icon" // {default = true;};
      variant = mkOption {
        type = nullOr (enum ["light" "dark"]);
        default = null;
        description = ''
          Set the light or dark variant manually, instead of relying on `background`
        '';
      };

      override = mkOption {
        type = attrsOf attrs;
        default = {};
        example = {
          zsh = {
            name = "Zsh";
            icon = "";
            color = "#428850";
            cterm_color = "65";
          };
        };
        description = ''
          Your personal icon overrides.

          You can specify color or `cterm_color` instead of specifying both of
          them. `DevIcon` will be appended to `name`
        '';
      };
    };
  };
}
