{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;

  cfg = config.vim.formatter.conform-nvim.presets;
in {
  options.vim.formatter.conform-nvim.presets = {
    biome = {
      enable = mkFormatterPresetEnableOption {
        option = "biome";
        display = "Biome";
      };
    };
    biome-check = {
      enable = mkFormatterPresetEnableOption {
        option = "biome-check";
        display = "Biome";
        extra = "This variant runs automatic linter fixes.";
      };
    };
    biome-organize-imports = {
      enable = mkFormatterPresetEnableOption {
        option = "biome-organize-imports";
        display = "Biome";
        extra = "This variant organizes imports.";
      };
    };
  };

  config.vim.formatter.conform-nvim.setupOpts.formatters = {
    biome = mkIf cfg.biome.enable {
      command = "${pkgs.biome}/bin/biome";
    };
    biome-check = mkIf cfg.biome-check.enable {
      command = "${pkgs.biome}/bin/biome";
    };
    biome-organize-impors = mkIf cfg.biome-organize-imports.enable {
      command = "${pkgs.biome}/bin/biome";
    };
  };
}
