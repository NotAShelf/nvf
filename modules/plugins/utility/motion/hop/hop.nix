{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
  inherit (config.vim.lib) mkMappingOption;
in {
  options.vim.utility.motion.hop = {
    mappings = {
      hop = mkMappingOption "Jump to occurrences [hop.nvim]" "<leader>h";
    };

    enable = mkEnableOption "Hop.nvim plugin (easy motion)";
    setupOpts = mkPluginSetupOption "hop.nvim" {};
  };
}
