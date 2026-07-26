{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;
  inherit (lib.meta) getExe';

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
      command = getExe' pkgs.clang-tools "clang-format";
    };
  };
}
