{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
  inherit (config.vim.lib) mkMappingOption;
in {
  options.vim.utility.motion.flash-nvim = {
    enable = mkEnableOption "enhanced code navigation with flash.nvim";
    setupOpts = mkPluginSetupOption "flash-nvim" {};

    mappings = {
      jump = mkMappingOption "Jump" "s";
      treesitter = mkMappingOption "Treesitter" "S";
      remote = mkMappingOption "Remote Flash" "r";
      treesitter_search = mkMappingOption "Treesitter Search" "R";
      toggle = mkMappingOption "Toggle Flash Search" "<c-s>";
    };
  };
}
