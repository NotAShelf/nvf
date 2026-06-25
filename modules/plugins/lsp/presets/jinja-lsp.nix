{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.jinja-lsp;
in {
  options.vim.lsp.presets.jinja-lsp = {
    enable = mkLspPresetEnableOption "jinja-lsp" "Jinja" [];
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.jinja-lsp = {
      enable = true;
      cmd = [(getExe pkgs.jinja-lsp)];
      root_markers = [".git"];
    };
  };
}
