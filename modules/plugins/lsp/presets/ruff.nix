{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.ruff;
in {
  options.vim.lsp.presets.ruff = {
    enable = mkLspPresetEnableOption {
      option = "ruff";
      display = "Ruff";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.ruff = {
      enable = true;
      cmd = ["${pkgs.ruff}/bin/ruff" "server"];
      root_markers = [".git"];
    };
  };
}
