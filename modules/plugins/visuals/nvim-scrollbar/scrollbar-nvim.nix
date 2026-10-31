{lib, ...}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) listOf str;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.visuals.nvim-scrollbar = {
    enable = mkEnableOption "extensible Neovim Scrollbar  [nvim-scrollbar]";
    setupOpts = mkPluginSetupOption "scrollbar-nvim" {
      excluded_filetypes = mkOption {
        type = listOf str;
        default = ["prompt" "TelescopePrompt" "noice" "NvimTree" "neo-tree" "alpha" "notify" "Navbuddy" "fastaction_popup"];
        description = "Filetypes to hide the scrollbar on";
      };
    };
  };
}
