{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.twig-language-server;
in {
  options.vim.lsp.presets.twig-language-server = {
    enable = mkLspPresetEnableOption {
      option = "twig-language-server";
      display = "Twig";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.twig-language-server = {
      enable = true;
      cmd = ["${pkgs.twig-language-server}/bin/twig-language-server" "--stdio"];
      root_markers = [".git"];
    };
  };
}
