{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.zls;
in {
  options.vim.lsp.presets.zls = {
    enable = mkLspPresetEnableOption {
      option = "zls";
      display = "Zig";
      inherit config;
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.zls = {
      enable = true;
      cmd = [(getExe pkgs.zls)];
      root_markers = [".git" "zls.json"];
      workspace_required = false;
    };
  };
}
