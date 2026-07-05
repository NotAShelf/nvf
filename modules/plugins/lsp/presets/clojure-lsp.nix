{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.clojure-lsp;
in {
  options.vim.lsp.presets.clojure-lsp = {
    enable = mkLspPresetEnableOption {
      option = "clojure-lsp";
      display = "Clojure";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.clojure-lsp = {
      enable = true;
      cmd = ["${pkgs.clojure-lsp}/bin/clojure-lsp"];
      root_markers = [".git" "project.clj"];
    };
  };
}
