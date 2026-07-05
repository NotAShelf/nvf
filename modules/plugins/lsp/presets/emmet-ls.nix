{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.emmet-ls;
in {
  options.vim.lsp.presets.emmet-ls = {
    enable = mkLspPresetEnableOption {
      option = "emmet-ls";
      display = "Emmet";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.emmet-ls = {
      enable = true;
      cmd = ["${pkgs.emmet-ls}/bin/emmet-ls" "--stdio"];
      root_markers = [".git"];
    };
  };
}
