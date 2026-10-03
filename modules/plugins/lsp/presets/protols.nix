{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;
  inherit (lib.meta) getExe;

  cfg = config.vim.lsp.presets.protols;
in {
  options.vim.lsp.presets.protols = {
    enable = mkLspPresetEnableOption {
      option = "protols";
      display = "Protols";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.protols = {
      enable = true;
      cmd = [(getExe pkgs.protols) "--stdio"];
      root_markers = ["protols.toml" ".git"];
    };
  };
}
