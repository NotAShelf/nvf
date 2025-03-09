{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.binds) addDescriptionsToMappings mkSetBinding;

  cfg = config.vim.lsp;

  self = import ./otter.nix {inherit lib;};
  mappingDefinitions = self.options.vim.lsp.otter-nvim.mappings;
  mappings = addDescriptionsToMappings cfg.otter-nvim.mappings mappingDefinitions;
in {
  config = mkIf (cfg.enable && cfg.otter-nvim.enable) {
    warnings = [
      # TODO: remove warning when we update to nvim 0.11
      (mkIf config.vim.utility.ccc.enable ''
        ccc and otter occasionally have small conflicts that will disappear with nvim 0.11.
        In the meantime, otter handles it by throwing a warning, but both plugins will work.
      '')
    ];
    vim = {
      startPlugins = ["otter-nvim"];

      maps.normal = mkMerge [
        (mkSetBinding mappings.toggle "<cmd>lua require'otter'.activate()<CR>")
      ];

      pluginRC.otter-nvim = entryAnywhere ''
        -- Enable otter diagnostics viewer
        require("otter").setup(${toLuaObject cfg.otter-nvim.setupOpts})
      '';
    };
  };
}
