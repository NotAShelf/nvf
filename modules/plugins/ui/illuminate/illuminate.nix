{lib, ...}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) listOf str;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.ui.illuminate = {
    enable = mkEnableOption ''
      automatically highlight other uses of the word under the cursor [vim-illuminate]
    '';

    setupOpts = mkPluginSetupOption "vim-illuminate" {
      filetypes_denylist = mkOption {
        type = listOf str;
        default = ["dirvish" "fugitive" "NvimTree" "TelescopePrompt"];
        description = "Filetypes to not illuminate, this overrides `filetypes_allowlist`";
      };
    };
  };
}
