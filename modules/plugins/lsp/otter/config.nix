{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.dag) entryAnywhere;
<<<<<<< HEAD
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

=======
  inherit (lib.nvim.binds) addDescriptionsToMappings mkSetBinding;

  cfg = config.vim.lsp;

  self = import ./otter.nix {inherit lib;};
  mappingDefinitions = self.options.vim.lsp.otter.mappings;
  mappings = addDescriptionsToMappings cfg.otter.mappings mappingDefinitions;
in {
  config = mkIf (cfg.enable && cfg.otter.enable) {
    vim = {
      startPlugins = ["otter"];

>>>>>>> d61aba1 (created otter file)
      maps.normal = mkMerge [
        (mkSetBinding mappings.toggle "<cmd>lua require'otter'.activate()<CR>")
      ];

<<<<<<< HEAD
      pluginRC.otter-nvim = entryAnywhere ''
        -- Enable otter diagnostics viewer
        require("otter").setup({${toLuaObject cfg.otter-nvim.setupOpts}})
=======
      pluginRC.otter = entryAnywhere ''
        -- Enable otter diagnostics viewer
        require("otter").setup {}
>>>>>>> d61aba1 (created otter file)
      '';
    };
  };
}
