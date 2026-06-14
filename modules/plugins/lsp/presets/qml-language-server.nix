{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.qmlls;
in {
  options.vim.lsp.presets.qml-language-server = {
    enable = mkLspPresetEnableOption "qml-language-server" "QML" [];
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.qml-language-server = {
      enable = true;
      cmd = [(getExe pkgs.qml-language-server)];
      root_markers = [
        ".git"
        "qmldir"
        "shell.qml"
      ];
    };
  };
}
