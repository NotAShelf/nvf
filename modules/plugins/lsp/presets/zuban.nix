{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.zuban;
in {
  options.vim.lsp.presets.zuban = {
    enable = mkLspPresetEnableOption {
      option = "zuban";
      display = "Zuban";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.zuban = {
      enable = true;
      cmd = ["${pkgs.zuban}/bin/zuban" "server"];
      root_markers = [".git"];
    };
  };
}
