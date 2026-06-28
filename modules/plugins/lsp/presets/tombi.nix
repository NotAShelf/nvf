{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.tombi;
in {
  options.vim.lsp.presets.tombi = {
    enable = mkLspPresetEnableOption {
      option = "tombi";
      display = "Tombi (AI Slop)";
      inherit config;
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.tombi = {
      enable = true;
      cmd = [(getExe pkgs.tombi) "lsp"];
      root_markers = [".git" "tombi.toml"];
    };
  };
}
