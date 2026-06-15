{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;

  cfg = config.vim.formatter.conform-nvim.presets.mdformat;
in {
  options.vim.formatter.conform-nvim.presets.mdformat = {
    enable = mkFormatterPresetEnableOption {
      option = "mdformat";
      display = "Mdformat";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.mdformat = {
      command = "${pkgs.python314Packages.python.withPackages (py:
        with py; [
          mdformat
          mdformat-gfm
          mdformat-front-matters
          mdformat-footnote
          mdformat-wikilink
        ])}/bin/mdformat";
    };
  };
}
