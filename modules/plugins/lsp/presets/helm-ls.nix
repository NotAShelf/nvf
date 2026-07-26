{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;
  inherit (lib.meta) getExe;

  cfg = config.vim.lsp.presets.helm-ls;
in {
  options.vim.lsp.presets.helm-ls = {
    enable = mkLspPresetEnableOption {
      option = "helm-ls";
      display = "Helm";
    };
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
