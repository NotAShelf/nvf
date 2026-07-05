{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.qmlls;
in {
  options.vim.lsp.presets.qmlls = {
    enable = mkLspPresetEnableOption {
      option = "qmlls";
      display = "QML";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.qmlls = {
      enable = true;
      cmd = ["${pkgs.kdePackages.qtdeclarative}/bin/qmlls"];
      root_markers = [".git"];
    };
  };
}
