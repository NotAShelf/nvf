{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;
  inherit (lib.meta) getExe;

  cfg = config.vim.lsp.presets.pyrefly;
in {
  options.vim.lsp.presets.pyrefly = {
    enable = mkLspPresetEnableOption {
      option = "pyrefly";
      display = "Pyrefly";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.pyrefly = {
      enable = true;
      cmd = [(getExe pkgs.pyrefly) "lsp"];
      root_markers = [".git" "pyrefly.toml"];
    };
  };
}
