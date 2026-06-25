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
    enable = mkLspPresetEnableOption "wgsl-analyzer" "WGSL Analyzer" [];
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.wgsl-analyzer = {
      enable = true;
      cmd = [(getExe pkgs.wgsl-analyzer)];
      root_markers = [".git"];
    };
  };
}
