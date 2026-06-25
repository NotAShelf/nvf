{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.cue;
in {
  options.vim.lsp.presets.cue = {
    enable = mkLspPresetEnableOption "cue" "Cue" [];
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.cue = {
      enable = true;
      cmd = [(getExe pkgs.cue) "lsp"];
      root_markers = [".git" "cue.mod"];
    };
  };
}
