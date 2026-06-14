{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;

  cfg = config.vim.formatter.conform-nvim.presets.terraform;
in {
  options.vim.formatter.conform-nvim.presets.terraform = {
    enable = mkFormatterPresetEnableOption {
      option = "terraform";
      display = "Terraform";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.terraform = {
      command = "${pkgs.terraform}/bin/terraform";
      args = ["fmt" "-no-color" "$FILENAME"];
      stdin = false;
    };
  };
}
