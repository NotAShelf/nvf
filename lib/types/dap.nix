{lib}: let
  inherit (lib.options) mkEnableOption;

  mkDapPresetEnableOption = {
    option,
    display,
    extra ? "",
  }:
    mkEnableOption ''
      the ${display} debug adapter.

      ${extra}

      Use {option}`vim.debugger.nvim-dap.adapters.${option}` for customization

      A configuration is also needed for your filetype in
      {option}`vim.debugger.nvim-dap.configurations`.
    '';
in {
  inherit mkDapPresetEnableOption;
}
