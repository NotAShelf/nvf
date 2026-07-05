{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.jls;
in {
  options.vim.lsp.presets.jls = {
    enable = mkLspPresetEnableOption {
      option = "jls";
      display = "NeoVim Java";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.jls = {
      enable = true;
      cmd = ["${inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.jls}/bin/jls"];
      root_markers = [
        ".git"
        ".java-version"
        "pom.xml"
        "build.xml"
        "build.gradle"
        "build.gradle.kts"
        "settings.gradle"
        "settings.gradle.kts"
      ];
    };
  };
}
