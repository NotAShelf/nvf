{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.nil;
in {
  options.vim.lsp.presets.nil = {
    enable = mkLspPresetEnableOption "nil" "Nil" [];
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.nil = {
      enable = true;
      cmd = [(getExe pkgs.nil)];
      root_markers = [".git"];
      settings.nil.nix.autoArchive = true;
    };
  };
}
