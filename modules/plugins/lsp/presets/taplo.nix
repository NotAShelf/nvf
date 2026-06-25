{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.taplo;
in {
  options.vim.lsp.presets.taplo = {
    enable = mkLspPresetEnableOption "taplo" "Taplo" [];
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.taplo = {
      enable = true;
      cmd = [(getExe pkgs.taplo) "lsp" "stdio"];
      root_markers = [".git"];
    };
  };
}
