{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.superhtml;
in {
  options.vim.lsp.presets.superhtml = {
    enable = mkLspPresetEnableOption {
      option = "superhtml";
      display = "SuperHTML";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.superhtml = {
      enable = true;
      cmd = ["${pkgs.superhtml}/bin/superhtml" "lsp"];
      root_markers = [".git"];
    };
  };
}
