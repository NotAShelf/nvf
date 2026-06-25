{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.superhtml;
in {
  options.vim.lsp.presets.superhtml = {
    enable = mkLspPresetEnableOption "superhtml" "SuperHTML" [];
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.superhtml = {
      enable = true;
      cmd = [(getExe pkgs.superhtml) "lsp"];
      root_markers = [".git"];
    };
  };
}
