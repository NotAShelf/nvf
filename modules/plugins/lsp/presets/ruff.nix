{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.ruff;
in {
  options.vim.lsp.presets.ruff = {
    enable = mkLspPresetEnableOption {
      option = "ruff";
      display = "Ruff";
      inherit config;
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.ruff = {
      enable = true;
      cmd = [(getExe pkgs.ruff) "server"];
      root_markers = [".git"];
    };
  };
}
