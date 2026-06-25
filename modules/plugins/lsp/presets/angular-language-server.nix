{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.angular-language-server;
in {
  options.vim.lsp.presets.angular-language-server = {
    enable = mkLspPresetEnableOption "angular-language-server" "Angular Template" [];
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.angular-language-server = {
      enable = true;
      cmd = [(getExe pkgs.angular-language-server) "--stdio"];
      root_markers = ["angular.json" "nx.json"];
    };
  };
}
