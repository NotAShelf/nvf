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
    assertions = [
      {
        assertion = !config.vim.utility.ccc.enable;
        message = ''
          ccc and otter have a breaking conflict. It's been reported upstream. Until it's fixed, disable one of them
        '';
      }
    ];
    vim = {
      startPlugins = ["otter-nvim"];

      maps.normal = mkMerge [
        (mkSetBinding mappings.toggle "<cmd>lua require'otter'.activate()<CR>")
      ];

      pluginRC.otter-nvim = entryAnywhere ''
        -- Enable otter diagnostics viewer
        require("otter").setup({${toLuaObject cfg.otter-nvim.setupOpts}})
      '';
    };
  };
}
