{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;
  inherit (lib.meta) getExe;

  cfg = config.vim.lsp.presets.awk-language-server;
in {
  options.vim.lsp.presets.awk-language-server = {
    enable = mkLspPresetEnableOption {
      option = "awk-language-server";
      display = "AWK";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.awk-language-server = {
      enable = true;
      cmd = [(getExe pkgs.awk-language-server)];
      root_markers = [".git"];
    };
  };
}
