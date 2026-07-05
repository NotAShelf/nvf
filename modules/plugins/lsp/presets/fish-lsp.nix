{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.fish-lsp;
in {
  options.vim.lsp.presets.fish-lsp = {
    enable = mkLspPresetEnableOption {
      option = "fish-lsp";
      display = "Fish";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.fish-lsp = {
      enable = true;
      cmd = ["${pkgs.fish-lsp}/bin/fish-lsp" "start"];
      root_markers = ["config.fish" ".git"];
    };
  };
}
