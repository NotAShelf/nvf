{lib, ...}: let
  inherit (lib.options) mkOption;
  inherit (lib.types) bool;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.utility.surround = {
    enable = mkOption {
      type = bool;
      default = false;
      description = ''
        nvim-surround: add/change/delete surrounding delimiter pairs with ease.
        Note that the default mappings deviate from upstreeam to avoid conflicts
        with nvim-leap.
      '';
    };
    setupOpts = mkPluginSetupOption "nvim-surround" {};

    useVendoredKeybindings = mkOption {
      type = bool;
      default = true;
      description = "Use alternative set of keybindings that avoids conflicts with other popular plugins, e.g. nvim-leap";
    };
  };
}
