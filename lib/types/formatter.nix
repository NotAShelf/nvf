{lib}: let
  inherit (lib.options) mkEnableOption;

  mkFormatterPresetEnableOption = {
    option,
    display,
    extra ? "",
  }:
    mkEnableOption ''
      the ${display} formatter.

      ${extra}

      Use `vim.formatter.conform-nvim.setupOpts.formatters.${option}` for customization
    '';
in {
  inherit mkFormatterPresetEnableOption;
}
