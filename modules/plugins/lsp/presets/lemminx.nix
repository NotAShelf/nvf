{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.lemminx;
in {
  options.vim.lsp.presets.lemminx = {
    enable = mkLspPresetEnableOption "lemminx" "Lemminx" [];
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.lemminx = {
      enable = true;
      cmd = [(getExe pkgs.lemminx)];
      root_markers = [".git"];
    };
  };
}
