{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;

  cfg = config.vim.formatter.conform-nvim.presets.hclfmt;
in {
  options.vim.formatter.conform-nvim.presets.hclfmt = {
    enable = mkFormatterPresetEnableOption {
      option = "hclfmt";
      display = "HCL";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.hclfmt = {
      command = "${pkgs.hclfmt}/bin/hclfmt";
      stdin = true;
    };
  };
}
