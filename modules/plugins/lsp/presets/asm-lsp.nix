{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.asm-lsp;
in {
  options.vim.lsp.presets.asm-lsp = {
    enable = mkLspPresetEnableOption "asm-lsp" "Assembly" [];
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.asm-lsp = {
      enable = true;
      cmd = [(getExe pkgs.asm-lsp)];
      root_markers = [".git" ".asm-lsp.toml"];
    };
  };
}
