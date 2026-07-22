{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;
  inherit (lib.meta) getExe;

  cfg = config.vim.lsp.presets.ty;
in {
  options.vim.lsp.presets.ty = {
    enable = mkLspPresetEnableOption {
      option = "ty";
      display = "ty";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.ty = {
      enable = true;
      cmd = [(getExe pkgs.ty) "server"];
      root_markers = [".git"];
    };
  };
}
