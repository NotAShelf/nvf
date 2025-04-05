{lib, ...}: let
  inherit (lib.nvim.types) mkPluginSetupOption;
  inherit (lib.options) literalMD mkEnableOption mkOption;
  inherit (lib.types) listOf str;
in {
  options.vim.ui.dressing = {
    enable = mkEnableOption "auto-save";
    setupOpts = mkPluginSetupOption "dressing" {
      select = {
        backend = mkOption {
          type = listOf str;
          default = ["fzf_lua"];
          description = literalMD ''
            Priority list of preferred `vim.select` implementations.
            Note: Using the default value(`["fzf_lua"]`) will also enable `fzf-lua`.
          '';
        };
      };
    };
  };
}
