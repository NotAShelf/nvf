{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.binds) addDescriptionsToMappings mkSetBinding;

  cfg = config.vim.lsp;

  self = import ./otter.nix {inherit lib;};
  mappingDefinitions = self.options.vim.lsp.otter.mappings;
  mappings = addDescriptionsToMappings cfg.otter.mappings mappingDefinitions;
in {
  config = mkIf (cfg.enable && cfg.otter.enable) {
    vim = {
      startPlugins = ["otter-nvim"];

      maps.normal = mkMerge [
        (mkSetBinding mappings.toggle "<cmd>lua require'otter'.activate()<CR>")
      ];

      pluginRC.otter = entryAnywhere ''
        -- Enable otter diagnostics viewer
        require("otter").setup()
      '';
    };
  };
}
