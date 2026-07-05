{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.wgsl-analyzer;
in {
  options.vim.lsp.presets.wgsl-analyzer = {
    enable = mkLspPresetEnableOption {
      option = "wgsl-analyzer";
      display = "WGSL Analyzer";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.wgsl-analyzer = {
      enable = true;
      cmd = ["${pkgs.wgsl-analyzer}/bin/wgsl-analyzer"];
      root_markers = [".git"];
    };
  };
}
