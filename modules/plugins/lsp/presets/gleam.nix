{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.gleam;
in {
  options.vim.lsp.presets.gleam = {
    enable = mkLspPresetEnableOption "gleam" "Gleam" [];
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.gleam = {
      enable = true;
      cmd = [(getExe pkgs.gleam) "lsp"];
      root_markers = [".git" "gleam.toml"];
    };
  };
}
