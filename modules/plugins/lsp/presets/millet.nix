{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.millet;
in {
  options.vim.lsp.presets.millet = {
    enable = mkLspPresetEnableOption {
      option = "millet";
      display = "Millet Standard ML";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.millet = {
      enable = true;
      cmd = ["${pkgs.millet}/bin/millet-ls"];
      root_markers = [".git" "millet.toml"];
    };
  };
}
