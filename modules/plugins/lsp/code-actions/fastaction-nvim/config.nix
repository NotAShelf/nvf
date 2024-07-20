{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.binds) addDescriptionsToMappings mkSetLuaBinding pushDownDefault;

  cfg = config.vim.lsp.code-actions;
  self = import ./fastaction-nvim.nix {inherit lib;};

  mappingDefinitions = self.options.vim.lsp.code-actions.fastaction-nvim.mappings;
  mappings = addDescriptionsToMappings cfg.fastaction-nvim.mappings mappingDefinitions;
in {
  config = mkIf (cfg.enable && cfg.fastaction-nvim.enable) {
    vim = {
      startPlugins = ["fastaction-nvim"];

      binds.whichKey.register = pushDownDefault {
        "<leader>c" = "Code Actions";
      };

      maps = {
        normal = mkSetLuaBinding mappings.code_action "require('fastaction').code_action";
        visual = mkSetLuaBinding mappings.range_action "require('fastaction').range_code_action";
      };

      pluginRC.fastaction-nvim = entryAnywhere ''
        -- Enable trouble diagnostics viewer
        require('fastaction').setup(${toLuaObject cfg.fastaction-nvim.setupOpts})
      '';
    };
  };
}
