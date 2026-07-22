{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;
  inherit (lib.meta) getExe;

  cfg = config.vim.formatter.conform-nvim.presets.opentofu;
in {
  options.vim.formatter.conform-nvim.presets.opentofu = {
    enable = mkFormatterPresetEnableOption {
      option = "opentofu";
      display = "OpenTofu";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.opentofu = {
      command = getExe pkgs.opentofu;
      args = ["fmt" "-no-color" "$FILENAME"];
      stdin = false;
    };
  };
}
