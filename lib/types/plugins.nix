{
  inputs,
  lib,
  ...
}: let
  inherit (lib.options) mkOption;
  inherit (lib.attrsets) attrNames mapAttrs' filterAttrs nameValuePair;
  inherit (lib.strings) hasPrefix removePrefix;
  inherit (lib.types) submodule either package enum str lines attrsOf anything listOf nullOr oneOf bool int;
  # Get the names of all flake inputs that start with the given prefix.
  fromInputs = {
    inputs,
    prefix,
  }:
    mapAttrs' (n: v: nameValuePair (removePrefix prefix n) {src = v;}) (filterAttrs (n: _: hasPrefix prefix n) inputs);

  #  Get the names of all flake inputs that start with the given prefix.
  pluginInputNames = attrNames (fromInputs {
    inherit inputs;
    prefix = "plugin-";
  });

  # You can either use the name of the plugin or a package.
  pluginType = nullOr (
    either
    package
    (enum (pluginInputNames ++ ["nvim-treesitter" "flutter-tools-patched" "vim-repeat"]))
  );

  pluginsType = listOf pluginType;

  extraPluginType = submodule {
    options = {
      package = mkOption {
        type = pluginType;
        description = "Plugin Package.";
      };

      after = mkOption {
        type = listOf str;
        default = [];
        description = "Setup this plugin after the following ones.";
      };

      setup = mkOption {
        type = lines;
        default = "";
        description = "Lua code to run during setup.";
        example = "require('aerial').setup {}";
      };
    };
  };

  borderPresets = ["none" "single" "double" "rounded" "solid" "shadow"];
  luaInline = lib.mkOptionType {
    name = "luaInline";
    check = x: lib.nvim.lua.isLuaInline x;
  };

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

  lznPluginTableType = attrsOf lznPluginType;
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
  inherit extraPluginType fromInputs pluginType luaInline lznPluginType lznPluginTableType;

  borderType = either (enum borderPresets) (listOf (either str (listOf str)));

  pluginsOpt = {
    description,
    example,
    default ? [],
  }:
    mkOption {
      inherit example description default;
      type = pluginsType;
    };

  /*
  opts is a attrset of options, example:
  ```
  mkPluginSetupOption "telescope" {
    file_ignore_patterns = mkOption {
      description = "...";
      type = types.listOf types.str;
      default = [];
    };
    layout_config.horizontal = mkOption {...};
  }
  ```
  */
  mkPluginSetupOption = pluginName: opts:
    mkOption {
      description = ''
        Option table to pass into the setup function of ${pluginName}

        You can pass in any additional options even if they're
        not listed in the docs
      '';

      default = {};
      type = submodule {
        freeformType = attrsOf anything;
        options = opts;
      };
    };
}
