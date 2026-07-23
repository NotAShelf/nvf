{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;
  inherit (lib.meta) getExe;

  cfg = config.vim.lsp.presets.marksman;
in {
  options.vim.lsp.presets.marksman = {
    enable = mkLspPresetEnableOption {
      option = "marksman";
      display = "Marksman";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.marksman = {
      enable = true;
      cmd = [(getExe pkgs.marksman) "server"];
      root_markers = [".git" ".marksman.toml"];
    };
  };
}
