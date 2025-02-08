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
        #inherit (cfg) setupOpts;
        setupOpts = {
          DEBUG_MODE = true;
          create_commands = true;
          updatetime = 50;
          nowait = true;
          mode_keys = {
            append = "a";
            change = "c";
            extend = "e";
            insert = "i";
          };
          hint_config = {
            float_opts = {
              border = "none";
            };
            position = "bottom";
          };
          generate_hints = {
            normal = true;
            insert = true;
            extend = true;
            config = {
              column_count = null;
              max_hint_length = 25;
            };
          };
        };

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
