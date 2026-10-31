{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
  mkMappingOption = config.vim.lib.mkMappingOption "hop.nvim";
in {
  options.vim.utility.motion.hop = {
    mappings = {
      hop = mkMappingOption "Jump to occurrences" "<leader>h";
    };

    enable = mkEnableOption "Hop.nvim plugin (easy motion)";
    setupOpts = mkPluginSetupOption "hop.nvim" {};
  };
}
