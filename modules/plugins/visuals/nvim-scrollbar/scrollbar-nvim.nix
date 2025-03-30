{lib, ...}: let
  inherit (lib.modules) mkRenamedOptionModule;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) listOf str;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  imports = [
    (mkRenamedOptionModule ["vim" "visuals" "scrollBar"] ["vim" "visuals" "nvim-scrollbar"])
  ];

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
