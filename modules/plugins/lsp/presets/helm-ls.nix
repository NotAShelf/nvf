{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.helm-ls;
in {
  options.vim.lsp.presets.helm-ls = {
    enable = mkLspPresetEnableOption "helm-ls" "Helm" [];
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.helm-ls = {
      enable = true;
      cmd = [(getExe pkgs.helm-ls) "serve"];
      root_markers = [".git" "Chart.yaml"];
      capabilities = {
        didChangeWatchedFiles = {
          dynamicRegistration = true;
        };
      };
    };
  };
}
