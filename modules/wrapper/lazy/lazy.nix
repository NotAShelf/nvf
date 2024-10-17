{lib, ...}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) enum listOf submodule nullOr str bool int attrsOf anything either oneOf;
  inherit (lib.nvim.types) pluginType;
  inherit (lib.nvim.config) mkBool;

  lznKeysSpec = submodule {
    options = {
      key = mkOption {
        type = nullOr str;
        description = "Key to bind to. If key is null this entry is ignored.";
      };

      action = mkOption {
        type = nullOr str;
        default = null;
        description = "Action to trigger.";
      };
      lua = mkBool false ''
        If true, `action` is considered to be lua code.
        Thus, it will not be wrapped in `""`.
      '';

      desc = mkOption {
        description = "Description of the key map";
        type = nullOr str;
        default = null;
      };

      ft = mkOption {
        description = "TBD";
        type = nullOr (listOf str);
        default = null;
      };

      mode = mkOption {
        description = "Modes to bind in";
        type = listOf str;
        default = ["n" "x" "s" "o"];
      };

      silent = mkBool true "Whether this mapping should be silent. Equivalent to adding <silent> to a map.";
      nowait = mkBool false "Whether to wait for extra input on ambiguous mappings. Equivalent to adding <nowait> to a map.";
      script = mkBool false "Equivalent to adding <script> to a map.";
      expr = mkBool false "Means that the action is actually an expression. Equivalent to adding <expr> to a map.";
      unique = mkBool false "Whether to fail if the map is already defined. Equivalent to adding <unique> to a map.";
      noremap = mkBool true "Whether to use the 'noremap' variant of the command, ignoring any custom mappings on the defined action. It is highly advised to keep this on, which is the default.";
    };
  };

  lznPluginType = submodule {
    options = {
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
        description = ''
          Lua code to run after plugin is loaded. This will be wrapped in a function.

          If [](#opt-vim.lazy.plugins._.setupModule) is provided, the setup will be ran before `after`.
        '';
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
            {
              mode = "n";
              key = "<leader>s";
              action = ":DapStepOver<cr>";
              desc = "DAP Step Over";
            }
            {
              mode = ["n", "x"];
              key = "<leader>dc";
              action = "function() require('dap').continue() end";
              lua = true;
              desc = "DAP Continue";
            }
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
      type = attrsOf lznPluginType;
      description = ''
        Plugins to lazy load.

        The attribute key is used as the plugin name: for the default `vim.g.lz_n.load`
        function this should be either the `package.pname` or `package.name`.
      '';
      example = ''
        {
          toggleterm-nvim = {
            package = "toggleterm-nvim";
            setupModule = "toggleterm";
            setupOpts = cfg.setupOpts;

            after = "require('toggleterm').do_something()";
            cmd = ["ToggleTerm"];
          };

          $${pkgs.vimPlugins.vim-bbye.pname} = {
            package = pkgs.vimPlugins.vim-bbye;
            cmd = ["Bdelete" "Bwipeout"];
          };
        }
      '';
    };
  };
}
