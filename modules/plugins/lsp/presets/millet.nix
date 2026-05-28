{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.millet;
in {
  options.vim.lsp.presets.millet = {
    enable = mkLspPresetEnableOption "millet" "Millet Standard ML" [];
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.millet = {
      enable = true;
      cmd = [(getExe pkgs.millet)];
      root_markers = [".git" "millet.toml"];
    };
  };
}
