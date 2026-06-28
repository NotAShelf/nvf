{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.phpantom;
in {
  options.vim.lsp.presets.phpantom = {
    enable = mkLspPresetEnableOption {
      option = "phpantom";
      display = "PHPantom";
      inherit config;
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.phpantom = {
      enable = true;
      cmd = [(getExe pkgs.phpantom-lsp)];
      root_markers = [".phpantom.toml" "composer.json" ".php-version" ".git"];
    };
  };
}
