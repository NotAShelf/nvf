{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.angular-language-server;
in {
  options.vim.lsp.presets.angular-language-server = {
    enable = mkLspPresetEnableOption {
      option = "angular-language-server";
      display = "Angular Template";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.angular-language-server = {
      enable = true;
      cmd = ["${pkgs.angular-language-server}/bin/ngserver" "--stdio"];
      root_markers = ["angular.json" "nx.json"];
      workspace_required = true;
    };
  };
}
