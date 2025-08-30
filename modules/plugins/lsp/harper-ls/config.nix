{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.meta) getExe;

  cfg = config.vim.lsp;
in {
  config = mkIf (cfg.enable && cfg.harper-ls.enable) {
    vim.lsp.servers.harper-ls = {
      root_markers = [".git"];
      cmd = [(getExe pkgs.harper) "--stdio"];
      settings = {harper-ls = cfg.harper-ls.settings;};
    };
  };
}
