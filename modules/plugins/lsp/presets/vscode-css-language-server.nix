{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.vscode-css-language-server;
in {
  options.vim.lsp.presets.vscode-css-language-server = {
    enable = mkLspPresetEnableOption {
      option = "vscode-css-language-server";
      display = "VSCode CSS";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.vscode-css-language-server = {
      enable = true;
      cmd = ["${pkgs.vscode-langservers-extracted}/bin/vscode-css-language-server" "--stdio"];
      root_markers = [".git" "package.json"];
      init_options = {provideFormatter = true;};
      settings = {
        css.validate = true;
        scss.validate = true;
        less.validate = true;
      };
    };
  };
}
