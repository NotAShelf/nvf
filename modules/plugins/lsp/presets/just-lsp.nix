{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;
  inherit (lib.meta) getExe;

  cfg = config.vim.lsp.presets.just-lsp;
in {
  options.vim.lsp.presets.just-lsp = {
    enable = mkLspPresetEnableOption {
      option = "just-lsp";
      display = "Just";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.just-lsp = {
      enable = true;
      cmd = [(getExe pkgs.just-lsp)];
      root_markers = [".git" "Justfile" "justfile"];
    };
  };
}
