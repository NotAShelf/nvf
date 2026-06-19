{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;

  cfg = config.vim.formatter.conform-nvim.presets.clang-format;
in {
  options.vim.formatter.conform-nvim.presets.clang-format = {
    enable = mkFormatterPresetEnableOption {
      option = "clang-format";
      display = "ClangFormat";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.clang-format = {
      command = "${pkgs.clang-tools}/bin/clang-format";
    };
  };
}
