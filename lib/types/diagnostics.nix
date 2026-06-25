{lib}: let
  inherit (lib.options) mkEnableOption;

  mkDiagnosticsPresetEnableOption = option: display:
    mkEnableOption ''
      the ${display} Diagnostics Provider.
      Use {option}`vim.diagnostics.nvim-lint.linters.${option}` for customization
    '';
in {
  inherit mkDiagnosticsPresetEnableOption;
}
