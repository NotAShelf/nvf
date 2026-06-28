{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.stimulus-language-server;
in {
  options.vim.lsp.presets.stimulus-language-server = {
    enable = mkLspPresetEnableOption {
      option = "stimulus-language-server";
      display = "Stimulus";
      inherit config;
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.stimulus-language-server = {
      enable = true;
      cmd = [(getExe inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.stimulus-language-server) "--stdio"];
      root_markers = [".git"];
      workspace_required = true;
    };
  };
}
