{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;

  cfg = config.vim.formatter.conform-nvim.presets.latexindent;
in {
  options.vim.formatter.conform-nvim.presets.latexindent = {
    enable = mkFormatterPresetEnableOption {
      option = "latexindent";
      display = "`latexindent.pl`";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.latexindent = {
      command = "${pkgs.texlive.withPackages (p: [p.latexindent])}/bin/latexindent";
    };
  };
}
