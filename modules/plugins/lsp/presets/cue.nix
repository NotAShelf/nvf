{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;
  inherit (lib.meta) getExe;

  cfg = config.vim.lsp.presets.cue;
in {
  options.vim.lsp.presets.cue = {
    enable = mkLspPresetEnableOption {
      option = "cue";
      display = "Cue";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.cue = {
      enable = true;
      cmd = [(getExe pkgs.cue) "lsp"];
      root_markers = [".git" "cue.mod"];
    };
  };
}
