{lib, ...}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) enum listOf submodule nullOr str bool int attrsOf anything either oneOf lines;
  inherit (lib.nvim.types) pluginType luaInline;
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
        type = nullOr str;
        default = null;
        description = "Description of the key map";
      };

      ft = mkOption {
        type = nullOr (listOf str);
        default = null;
        description = "TBD";
      };

      mode = mkOption {
        type = either str (listOf str);
        example = ["n" "x" "o"];
        description = "Modes to bind in";
      };

      silent = mkBool true "Whether this mapping should be silent. Equivalent to adding <silent> to a map.";
      nowait = mkBool false "Whether to wait for extra input on ambiguous mappings. Equivalent to adding <nowait> to a map.";
      script = mkBool false "Equivalent to adding <script> to a map.";
      expr = mkBool false "Means that the action is actually an expression. Equivalent to adding <expr> to a map.";
      unique = mkBool false "Whether to fail if the map is already defined. Equivalent to adding <unique> to a map.";
      noremap = mkBool true "Whether to use the 'noremap' variant of the command, ignoring any custom mappings on the defined action. It is highly advised to keep this on, which is the default.";
    };
  };

  lznEvent = submodule {
    options = {
      event = mkOption {
        type = nullOr (either str (listOf str));
        example = "BufEnter";
        description = "Exact event name";
      };
      pattern = mkOption {
        type = nullOr (either str (listOf str));
        example = "BufEnter *.lua";
        description = "Event pattern";
      };
    };
  };

  lznPluginType = submodule {
    options = {
      package = mkOption {
        type = nullOr pluginType;
        description = ''
          Plugin package.

          If null, a custom load function must be provided
        '';
      };

      beforeSetup = mkOption {
        type = nullOr lines;
        default = null;
        description = ''
          Lua code to run after the plugin is loaded, but before the setup
          function is called.
        '';
      };

      setupModule = mkOption {
        type = nullOr str;
        default = null;
        description = "Lua module to run setup function on.";
      };

      setupOpts = mkOption {
        type = attrsOf anything;
        default = {};
        description = "Options to pass to the setup function";
      };

      # lz.n options

      enabled = mkOption {
        type = nullOr (either bool luaInline);
        default = null;
        description = "When false, or if the lua function returns false, this plugin will not be included in the spec";
      };

      beforeAll = mkOption {
        type = nullOr lines;
        default = null;
        description = "Lua code to run before any plugins are loaded. This will be wrapped in a function.";
      };

      before = mkOption {
        type = nullOr lines;
        default = null;
        description = "Lua code to run before plugin is loaded. This will be wrapped in a function.";
      };

      after = mkOption {
        type = nullOr lines;
        default = null;
        description = ''
          Lua code to run after plugin is loaded. This will be wrapped in a function.

          If {option}`vim.lazy.plugins._name_.setupModule` is provided, the setup will be ran before `after`.
        '';
      };

      event = mkOption {
        type = nullOr (oneOf [str lznEvent (listOf (either str lznEvent))]);
        default = null;
        description = "Lazy-load on event";
      };

      cmd = mkOption {
        type = nullOr (either str (listOf str));
        default = null;
        description = "Lazy-load on command";
      };

      ft = mkOption {
        type = nullOr (either str (listOf str));
        default = null;
        description = "Lazy-load on filetype";
      };

      keys = mkOption {
        type = nullOr (oneOf [str (listOf lznKeysSpec) (listOf str)]);
        default = null;
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
        description = "Lazy-load on key mapping";
      };

      colorscheme = mkOption {
        type = nullOr (either str (listOf str));
        default = null;
        description = "Lazy-load on colorscheme.";
      };

      lazy = mkOption {
        type = nullOr bool;
        default = null;
        description = ''
          Force enable/disable lazy-loading. `null` means only lazy-load if
          a valid lazy-load condition is set e.g. `cmd`, `ft`, `keys` etc.
        '';
      };

      priority = mkOption {
        type = nullOr int;
        default = null;
        description = "Only useful for stat plugins (not lazy-loaded) to force loading certain plugins first.";
      };

      load = mkOption {
        type = nullOr lines;
        default = null;
        description = ''
          Lua code to override the `vim.g.lz_n.load()` function for a single plugin.

          This will be wrapped in a `function(name) ... end`.
        '';
      };
    };
  };
in {
  options.vim.lazy = {
    enable = mkEnableOption "plugin lazy-loading via lz.n and lzn-auto-require" // {default = true;};
    loader = mkOption {
      type = enum ["lz.n"];
      default = "lz.n";
      description = "Lazy loader to use";
    };

    plugins = mkOption {
      type = attrsOf lznPluginType;
      default = {};
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
      description = ''
        Plugins to lazy load.

        The attribute key is used as the plugin name: for the default `vim.g.lz_n.load`
        function this should be either the `package.pname` or `package.name`.
      '';
    };

    enableLznAutoRequire = mkOption {
      type = bool;
      default = true;
      description = ''
        Enable lzn-auto-require. Since builtin plugins rely on this, only turn
        off for debugging.
      '';
    };

    builtLazyConfig = mkOption {
      internal = true;
      type = lines;
      description = ''
        The built config for lz.n, or if `vim.lazy.enable` is false, the
        individual plugin configs.
      '';
    };
  };
}
