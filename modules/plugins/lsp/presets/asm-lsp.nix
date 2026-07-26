{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;
  inherit (lib.meta) getExe;

  cfg = config.vim.lsp.presets.asm-lsp;
in {
  options.vim.lsp.presets.asm-lsp = {
    enable = mkLspPresetEnableOption {
      option = "asm-lsp";
      display = "Assembly";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.asm-lsp = {
      enable = true;
      cmd = [(getExe pkgs.asm-lsp)];
      root_markers = [".git" ".asm-lsp.toml"];
    };
  };
}
