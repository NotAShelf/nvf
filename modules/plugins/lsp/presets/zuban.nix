{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.zuban;
in {
  options.vim.lsp.presets.zuban = {
    enable = mkLspPresetEnableOption "zuban" "Zuban" [];
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.zuban = {
      enable = true;
      cmd = [(getExe pkgs.zuban) "server"];
      root_markers = [".git"];
    };
  };
}
