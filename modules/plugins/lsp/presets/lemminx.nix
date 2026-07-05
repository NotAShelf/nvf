{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.lemminx;
in {
  options.vim.lsp.presets.lemminx = {
    enable = mkLspPresetEnableOption {
      option = "lemminx";
      display = "Lemminx";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.lemminx = {
      enable = true;
      cmd = ["${pkgs.lemminx}/bin/lemminx"];
      root_markers = [".git"];
    };
  };
}
