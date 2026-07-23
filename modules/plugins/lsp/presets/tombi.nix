{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;
  inherit (lib.meta) getExe;

  cfg = config.vim.lsp.presets.tombi;
in {
  options.vim.lsp.presets.tombi = {
    enable = mkLspPresetEnableOption {
      option = "tombi";
      display = "Tombi (AI Slop)";
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
