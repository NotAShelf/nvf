{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.nixd;
in {
  options.vim.lsp.presets.nixd = {
    enable = mkLspPresetEnableOption {
      option = "nixd";
      display = "Nixd";
      inherit config;
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.nixd = {
      enable = true;
      cmd = [(getExe pkgs.nixd)];
      root_markers = [".git"];
    };
  };
}
