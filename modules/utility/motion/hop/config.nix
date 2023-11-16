{
  config,
  lib,
  ...
}: let
  inherit (lib) addDescriptionsToMappings mkIf mkSetBinding nvim;

  cfg = config.vim.utility.motion.hop;

  self = import ./hop.nix {inherit lib;};

  mappingDefinitions = self.options.vim.utility.motion.hop.mappings;
  mappings = addDescriptionsToMappings cfg.mappings mappingDefinitions;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = ["hop-nvim"];

    vim.maps.normal = mkSetBinding mappings.hop "<cmd> HopPattern<CR>";

    vim.luaConfigRC.hop-nvim = nvim.dag.entryAnywhere ''
      require('hop').setup()
    '';
  };
}
