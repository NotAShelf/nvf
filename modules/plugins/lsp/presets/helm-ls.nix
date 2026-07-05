{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

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
      cmd = ["${pkgs.helm-ls}/bin/helm_ls" "serve"];
      root_markers = [".git" "Chart.yaml"];
      capabilities = {
        didChangeWatchedFiles = {
          dynamicRegistration = true;
        };
      };
    };
  };
}
