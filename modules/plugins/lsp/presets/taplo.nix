{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.taplo;
in {
  options.vim.lsp.presets.taplo = {
    enable = mkLspPresetEnableOption {
      option = "taplo";
      display = "Taplo";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.taplo = {
      enable = true;
      cmd = ["${pkgs.taplo}/bin/taplo" "lsp" "stdio"];
      root_markers = [".git"];
    };
  };
}
