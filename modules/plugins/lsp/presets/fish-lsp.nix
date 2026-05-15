{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.fish-lsp;
in {
  options.vim.lsp.presets.fish-lsp = {
    enable = mkLspPresetEnableOption "fish-lsp" "Fish" [];
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.fish-lsp = {
      enable = true;
      cmd = [(getExe pkgs.fish-lsp) "start"];
      root_markers = ["config.fish" ".git"];
    };
  };
}
