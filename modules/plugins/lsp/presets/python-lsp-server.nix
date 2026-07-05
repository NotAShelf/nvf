{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.python-lsp-server;
in {
  options.vim.lsp.presets.python-lsp-server = {
    enable = mkLspPresetEnableOption {
      option = "python-lsp-server";
      display = "Python";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.python-lsp-server = {
      enable = true;
      cmd = ["${pkgs.python3Packages.python-lsp-server}/bin/pylsp"];
      root_markers = [".git"];
    };
  };
}
