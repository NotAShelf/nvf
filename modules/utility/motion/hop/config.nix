{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.binds) addDescriptionsToMappings mkSetBinding;
  inherit (lib.nvim.dag) entryAnywhere;

  cfg = config.vim.utility.motion.hop;

  self = import ./hop.nix {inherit lib;};

  mappingDefinitions = self.options.vim.utility.motion.hop.mappings;
  mappings = addDescriptionsToMappings cfg.mappings mappingDefinitions;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = ["hop-nvim"];

    vim.maps.normal = mkSetBinding mappings.hop "<cmd> HopPattern<CR>";

    vim.luaConfigRC.hop-nvim = entryAnywhere ''
      require('hop').setup()
    '';
  };
}
