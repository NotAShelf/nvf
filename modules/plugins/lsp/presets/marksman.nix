{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.marksman;
in {
  options.vim.lsp.presets.marksman = {
    enable = mkLspPresetEnableOption "marksman" "Marksman" [];
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.marksman = {
      enable = true;
      cmd = [(getExe pkgs.marksman) "server"];
      root_markers = [".git" ".marksman.toml"];
    };
  };
}
