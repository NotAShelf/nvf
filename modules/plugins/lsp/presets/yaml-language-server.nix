{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.yaml-language-server;
in {
  options.vim.lsp.presets.yaml-language-server = {
    enable = mkLspPresetEnableOption {
      option = "yaml-language-server";
      display = "YAML";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.yaml-language-server = {
      enable = true;
      cmd = ["${pkgs.yaml-language-server}/bin/yaml-language-server" "--stdio"];
      root_markers = [".git"];
      settings = {
        # https://github.com/redhat-developer/vscode-redhat-telemetry#how-to-disable-telemetry-reporting
        redhat = {
          telemetry = {
            enabled = false;
          };
        };
      };
    };
  };
}
