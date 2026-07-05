{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

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
      cmd = ["${pkgs.cue}/bin/cue" "lsp"];
      root_markers = [".git" "cue.mod"];
    };
  };
}
