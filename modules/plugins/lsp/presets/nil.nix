{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;
  inherit (lib.meta) getExe;

  cfg = config.vim.lsp.presets.nil;
in {
  options.vim.lsp.presets.nil = {
    enable = mkLspPresetEnableOption {
      option = "nil";
      display = "Nil";
    };
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
