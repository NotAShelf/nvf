{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.modules) mkRenamedOptionModule;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.meta) getExe;
  inherit (lib.types) str;
  inherit (lib.nvim.types) mkPluginSetupOption;
  inherit (config.vim.lib) mkMappingOption;
in {
  imports = [
    (mkRenamedOptionModule ["vim" "languages" "markdown" "glow" "enable"] ["vim" "utility" "preview" "glow" "enable"])
  ];

  options.vim.utility.preview = {
    glow = {
      enable = mkEnableOption "markdown preview in neovim with glow";
      mappings.openPreview = mkMappingOption "Open preview" "<leader>p";
      setupOpts = mkPluginSetupOption "glow.nvim" {
        glow_path = mkOption {
          type = str;
          default = getExe pkgs.glow;
          example = "glow";
          description = "Path to the glow binary.";
        };
      };
    };
  };
}
