{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.intelephense;
in {
  options.vim.lsp.presets.intelephense = {
    enable = mkLspPresetEnableOption {
      option = "intelephense";
      display = "Intelephense";
      extra = ''
        Free Tier. \
        If you wan't to use the premium tier, override
        {option}`vim.lsp.servers.inteliphense.cmd`
        to point to your paid binary.
      '';
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.intelephense = {
      enable = true;
      cmd = ["${pkgs.intelephense}/bin/intelephense" "--stdio"];
      root_markers = [".git"];
    };
  };
}
