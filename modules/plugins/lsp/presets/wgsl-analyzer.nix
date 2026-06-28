{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.wgsl-analyzer;
in {
  options.vim.lsp.presets.wgsl-analyzer = {
    enable = mkLspPresetEnableOption {
      option = "wgsl-analyzer";
      display = "WGSL Analyzer";
      inherit config;
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.wgsl-analyzer = {
      enable = true;
      cmd = [(getExe pkgs.wgsl-analyzer)];
      root_markers = [".git"];
    };
  };
}
