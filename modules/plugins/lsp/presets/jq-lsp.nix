{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.jq-lsp;
in {
  options.vim.lsp.presets.jq-lsp = {
    enable = mkLspPresetEnableOption "jq-lsp" "JQ" [];
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.jq-lsp = {
      enable = true;
      cmd = [(getExe pkgs.jq-lsp)];
      root_markers = [".git"];
    };
  };
}
