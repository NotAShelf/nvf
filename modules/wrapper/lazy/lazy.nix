{lib, ...}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) enum listOf submodule nullOr str bool int attrsOf anything either oneOf;
  inherit (lib.nvim.types) pluginType;

  lznKeysSpec = submodule {
    options = {
      desc = mkOption {
        description = "Description of the key map";
        type = nullOr str;
        default = null;
      };

      noremap = mkOption {
        description = "TBD";
        type = bool;
        default = false;
      };

      expr = mkOption {
        description = "TBD";
        type = bool;
        default = false;
      };

      nowait = mkOption {
        description = "TBD";
        type = bool;
        default = false;
      };

      ft = mkOption {
        description = "TBD";
        type = nullOr (listOf str);
        default = null;
      };

      key = mkOption {
        type = str;
        description = "Key to bind to";
      };

      action = mkOption {
        type = nullOr str;
        default = null;
        description = "Action to trigger.";
      };

      lua = mkOption {
        type = bool;
        default = false;
        description = "If true the action is treated as a lua function instead of a vim command.";
      };

      mode = mkOption {
        description = "Modes to bind in";
        type = listOf str;
        default = ["n" "x" "s" "o"];
      };
    };
  };

  lznPluginType = submodule {
    options = {
      ## Should probably infer from the actual plugin somehow
      ## In general this is the name passed to packadd, so the dir name of the plugin
      # name = mkOption {
      #   type=  str;
      # }

      # Non-lz.n options

      package = mkOption {
        type = pluginType;
        description = "Plugin package";
      };

      setupModule = mkOption {
        type = nullOr str;
        description = "Lua module to run setup function on.";
        default = null;
      };

      setupOpts = mkOption {
        type = submodule {freeformType = attrsOf anything;};
        description = "Options to pass to the setup function";
        default = {};
      };

      # lz.n options

      enabled = mkOption {
        type = nullOr (either bool str);
        description = "When false, or if the lua function returns false, this plugin will not be included in the spec";
        default = null;
      };

      beforeAll = mkOption {
        type = nullOr str;
        description = "Lua code to run before any plugins are loaded. This will be wrapped in a function.";
        default = null;
      };

      before = mkOption {
        type = nullOr str;
        description = "Lua code to run before plugin is loaded. This will be wrapped in a function.";
        default = null;
      };

      after = mkOption {
        type = nullOr str;
        description = "Lua code to run after plugin is loaded. This will be wrapped in a function.";
        default = null;
      };

      event = mkOption {
        description = "Lazy-load on event";
        default = null;
        type = let
          event = submodule {
            options = {
              event = mkOption {
                type = nullOr (either str (listOf str));
                description = "Exact event name";
                example = "BufEnter";
              };
              pattern = mkOption {
                type = nullOr (either str (listOf str));
                description = "Event pattern";
                example = "BufEnter *.lua";
              };
            };
          };
        in
          nullOr (oneOf [str (listOf str) event]);
      };

      cmd = mkOption {
        description = "Lazy-load on command";
        default = null;
        type = nullOr (either str (listOf str));
      };

      ft = mkOption {
        description = "Lazy-load on filetype";
        default = null;
        type = nullOr (either str (listOf str));
      };

      keys = mkOption {
        description = "Lazy-load on key mapping";
        default = null;
        type = nullOr (oneOf [str (listOf lznKeysSpec) (listOf str)]);
        example = ''
          keys = [
            {lhs = "<leader>s"; rhs = ":NvimTreeToggle<cr>"; desc = "Toggle NvimTree"}
          ]
        '';
      };

      colorscheme = mkOption {
        description = "Lazy-load on colorscheme.";
        type = nullOr (either str (listOf str));
        default = null;
      };

      priority = mkOption {
        type = nullOr int;
        description = "Only useful for stat plugins (not lazy-loaded) to force loading certain plugins first.";
        default = null;
      };

      load = mkOption {
        type = nullOr str;
        default = null;
        description = ''
          Lua code to override the `vim.g.lz_n.load()` function for a single plugin.

          This will be wrapped in a function
        '';
      };
    };
  };
in {
  options.vim.lazy = {
    enable = mkEnableOption "plugin lazy-loading" // {default = true;};
    loader = mkOption {
      description = "Lazy loader to use";
      type = enum ["lz.n"];
      default = "lz.n";
    };

    plugins = mkOption {
      default = [];
      type = listOf lznPluginType;
      description = "list of plugins to lazy load";
      example = ''
        [
          {
            package = "toggleterm-nvim";
            after = lib.generators.mkLuaInline "function() require('toggleterm').setup{} end";
            cmd = ["ToggleTerm"];
          }
        ]
      '';
    };
  };
}
