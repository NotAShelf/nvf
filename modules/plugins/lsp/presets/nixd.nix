{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.nixd;
in {
  options.vim.lsp.presets.nixd = {
    enable = mkLspPresetEnableOption {
      option = "nixd";
      display = "`nixd`";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.nixd = {
      enable = true;
      cmd = ["${pkgs.nixd}/bin/nixd"];
      root_markers = [".git"];
    };
  };
}
