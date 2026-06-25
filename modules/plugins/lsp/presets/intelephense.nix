{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.intelephense;
in {
  options.vim.lsp.presets.intelephense = {
    enable = mkLspPresetEnableOption "intelephense" "Intelephense" [];
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.intelephense = {
      enable = true;
      cmd = [(getExe pkgs.intelephense) "--stdio"];
      root_markers = [".git"];
    };
  };
}
