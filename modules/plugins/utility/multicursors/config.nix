{
  options,
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.binds) mkKeymap;
  inherit (lib.nvim.binds) addDescriptionsToMappings; # mkSetLuaBinding;
  cfg = config.vim.utility.multicursors;
  mappingDefinitions = options.vim.utility.multicursors.mappings;
  mappings = addDescriptionsToMappings cfg.mappings mappingDefinitions;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["hydra-nvim"];
      lazy.plugins.multicursors-nvim = {
        package = "multicursors-nvim";
        setupModule = "multicursors";
        inherit (cfg) setupOpts;

        event = ["DeferredUIEnter"];
        cmd = ["MCstart" "MCvisual" "MCclear" "MCpattern" "MCvisualPattern" "MCunderCursor"];
        keys = [
          {
            mode = ["v" "n"];
            key = "<leader>mcs";
            action = ":MCstart<cr>";
            desc = "Create a selection for selected text or word under the cursor [multicursors.nvim]";
          }
          {
            mode = ["v" "n"];
            key = "<leader>mcp";
            action = ":MCpattern<cr>";
            desc = "Create a selection for pattern entered [multicursors.nvim]";
          }
        ];
      };
    };
  };
}
