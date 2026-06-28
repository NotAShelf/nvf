{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.emmet-ls;
in {
  options.vim.lsp.presets.emmet-ls = {
    enable = mkLspPresetEnableOption {
      option = "emmet-ls";
      display = "Emmet";
      inherit config;
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.emmet-ls = {
      enable = true;
      cmd = [(getExe pkgs.emmet-ls) "--stdio"];
      root_markers = [".git"];
    };
  };
}
