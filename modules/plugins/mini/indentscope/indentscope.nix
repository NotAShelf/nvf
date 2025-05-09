{lib, ...}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
  inherit (lib.types) str listOf;
in {
  options.vim.mini.indentscope = {
    enable = mkEnableOption "mini.indentscope";
    setupOpts = mkPluginSetupOption "mini.indentscope" {
      ignore_filetypes = mkOption {
        type = listOf str;
        default = ["help" "neo-tree" "notify" "NvimTree" "TelescopePrompt"];
        description = "File types to ignore for illuminate";
      };
    };
  };
}
