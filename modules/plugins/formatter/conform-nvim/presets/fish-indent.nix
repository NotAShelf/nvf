{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;

  cfg = config.vim.formatter.conform-nvim.presets.fish-indent;
in {
  options.vim.formatter.conform-nvim.presets.fish-indent = {
    enable = mkFormatterPresetEnableOption {
      option = "fish-indent";
      display = "`fish_indent`";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.fish-indent = {
      command = "${pkgs.fish}/bin/fish_indent";
    };
  };
}
