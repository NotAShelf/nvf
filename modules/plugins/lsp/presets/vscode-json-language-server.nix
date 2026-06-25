{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe';
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.vscode-json-language-server;
in {
  options.vim.lsp.presets.vscode-json-language-server = {
    enable = mkLspPresetEnableOption "vscode-json-language-server" "VSCode JSON" [];
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.vscode-json-language-server = {
      enable = true;
      cmd = [(getExe' pkgs.vscode-langservers-extracted "vscode-json-language-server") "--stdio"];
      root_markers = [".git"];
      init_options = {provideFormatter = true;};
    };
  };
}
