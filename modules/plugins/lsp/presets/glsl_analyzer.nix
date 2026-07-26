{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;
  inherit (lib.meta) getExe;

  cfg = config.vim.lsp.presets.glsl_analyzer;
in {
  options.vim.lsp.presets.glsl_analyzer = {
    enable = mkLspPresetEnableOption {
      option = "glsl_analyzer";
      display = "GLSL Analyzer";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.glsl_analyzer = {
      enable = true;
      cmd = [(getExe pkgs.glsl_analyzer)];
      root_markers = [".git"];
    };
  };
}
