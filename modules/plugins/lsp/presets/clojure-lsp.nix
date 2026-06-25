{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.clojure-lsp;
in {
  options.vim.lsp.presets.clojure-lsp = {
    enable = mkLspPresetEnableOption "clojure-lsp" "Clojure" [];
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.clojure-lsp = {
      enable = true;
      cmd = [(getExe pkgs.clojure-lsp)];
      root_markers = [".git" "project.clj"];
    };
  };
}
