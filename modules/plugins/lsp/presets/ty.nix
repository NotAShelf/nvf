{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.ty;
in {
  options.vim.lsp.presets.ty = {
    enable = mkLspPresetEnableOption "ty" "ty" [];
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.ty = {
      enable = true;
      cmd = [(getExe pkgs.ty) "server"];
      root_markers = [".git"];
    };
  };
}
