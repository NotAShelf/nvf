{lib}: let
  inherit (lib.options) mkEnableOption;

  mkDiagnosticsPresetEnableOption = {
    option,
    display,
    extra ? "",
  }:
    mkEnableOption ''
      the ${display} Diagnostics Provider.

      ${extra}

      Use {option}`vim.diagnostics.nvim-lint.linters.${option}` for customization
    '';
in {
  inherit mkDiagnosticsPresetEnableOption;
}
