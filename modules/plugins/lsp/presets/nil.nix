{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

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
      cmd = ["${pkgs.nil}/bin/nil"];
      root_markers = [".git"];
      settings.nil.nix.autoArchive = true;
    };
  };
}
