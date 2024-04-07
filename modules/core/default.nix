{
  config,
  lib,
  ...
}: let
  inherit (builtins) attrValues attrNames map mapAttrs toJSON isString concatStringsSep filter;
  inherit (lib.options) mkOption literalExpression mdDoc;
  inherit (lib.attrsets) filterAttrs getAttrs;
  inherit (lib.strings) optionalString;
  inherit (lib.misc) mapAttrsFlatten;
  inherit (lib.trivial) showWarnings;
  inherit (lib.types) bool str listOf oneOf attrsOf nullOr attrs submodule unspecified lines;
  inherit (lib.nvim.types) dagOf pluginsOpt extraPluginType;
  inherit (lib.nvim.dag) entryAnywhere entryAfter topoSort;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.vim) valToVim;

  cfg = config.vim;

  wrapLuaConfig = luaConfig: ''
    lua << EOF
    ${optionalString cfg.enableLuaLoader ''
      vim.loader.enable()
    ''}
    ${luaConfig}
    EOF
  '';

  mkBool = value: description:
    mkOption {
      type = bool;
      default = value;
      inherit description;
    };

  # Most of the keybindings code is highly inspired by pta2002/nixvim. Thank you!
  mapConfigOptions = {
    silent =
      mkBool false
      "Whether this mapping should be silent. Equivalent to adding <silent> to a map.";

    nowait =
      mkBool false
      "Whether to wait for extra input on ambiguous mappings. Equivalent to adding <nowait> to a map.";

    script =
      mkBool false
      "Equivalent to adding <script> to a map.";

    expr =
      mkBool false
      "Means that the action is actually an expression. Equivalent to adding <expr> to a map.";

    unique =
      mkBool false
      "Whether to fail if the map is already defined. Equivalent to adding <unique> to a map.";

    noremap =
      mkBool true
      "Whether to use the 'noremap' variant of the command, ignoring any custom mappings on the defined action. It is highly advised to keep this on, which is the default.";

    desc = mkOption {
      type = nullOr str;
      default = null;
      description = "A description of this keybind, to be shown in which-key, if you have it enabled.";
    };
  };

  genMaps = mode: maps: let
    /*
    Take a user-defined action (string or attrs) and return the following attribute set:
    {
      action = (string) the actual action to map to this key
      config = (attrs) the configuration options for this mapping (noremap, silent...)
    }
    */
    normalizeAction = action: let
      # Extract the values of the config options that have been explicitly set by the user
      config =
        filterAttrs (_: v: v != null)
        (getAttrs (attrNames mapConfigOptions) action);
    in {
      config =
        if config == {}
        then {"__empty" = null;}
        else config;
      action =
        if action.lua
        then mkLuaInline action.action
        else action.action;
    };
  in
    attrValues (mapAttrs
      (key: action: let
        normalizedAction = normalizeAction action;
      in {
        inherit (normalizedAction) action config;
        inherit key;
        inherit mode;
      })
      maps);

  mapOption = submodule {
    options =
      mapConfigOptions
      // {
        action = mkOption {
          type = str;
          description = "The action to execute.";
        };

        lua = mkOption {
          type = bool;
          description = ''
            If true, `action` is considered to be lua code.
            Thus, it will not be wrapped in `""`.
          '';
          default = false;
        };
      };
  };

  mapOptions = mode:
    mkOption {
      description = "Mappings for ${mode} mode";
      type = attrsOf mapOption;
      default = {};
    };
in {
  options = {
    assertions = mkOption {
      type = listOf unspecified;
      internal = true;
      default = [];
      example = literalExpression ''
        [
          {
            assertion = false;
            message = "you can't enable this for that reason";
          }
        ]
      '';
    };

    warnings = mkOption {
      internal = true;
      default = [];
      type = listOf str;
      example = ["The `foo' service is deprecated and will go away soon!"];
      description = mdDoc ''
        This option allows modules to show warnings to users during
        the evaluation of the system configuration.
      '';
    };

    vim = {
      viAlias = mkOption {
        description = "Enable vi alias";
        type = bool;
        default = true;
      };

      vimAlias = mkOption {
        description = "Enable vim alias";
        type = bool;
        default = true;
      };

      configRC = mkOption {
        description = "vimrc contents";
        type = oneOf [(dagOf lines) str];
        default = {};
      };

      luaConfigRC = mkOption {
        description = "vim lua config";
        type = oneOf [(dagOf lines) str];
        default = {};
      };

      builtConfigRC = mkOption {
        internal = true;
        type = lines;
        description = "The built config for neovim after resolving the DAG";
      };

      startPlugins = pluginsOpt {
        default = [];
        description = "List of plugins to startup.";
      };

      optPlugins = pluginsOpt {
        default = [];
        description = "List of plugins to optionally load";
      };

      extraPlugins = mkOption {
        type = attrsOf extraPluginType;
        default = {};
        description = ''
          List of plugins and related config.
          Note that these are setup after builtin plugins.
        '';
        example = literalExpression ''
            with pkgs.vimPlugins; {
            aerial = {
              package = aerial-nvim;
              setup = "require('aerial').setup {}";
            };
            harpoon = {
              package = harpoon;
              setup = "require('harpoon').setup {}";
              after = ["aerial"];
            };
          }'';
      };

      luaPackages = mkOption {
        type = listOf str;
        default = [];
        description = ''
          List of lua packages to install.
        '';
      };

      globals = mkOption {
        default = {};
        description = "Set containing global variable values";
        type = attrs;
      };

      maps = mkOption {
        type = submodule {
          options = {
            normal = mapOptions "normal";
            insert = mapOptions "insert";
            select = mapOptions "select";
            visual = mapOptions "visual and select";
            terminal = mapOptions "terminal";
            normalVisualOp = mapOptions "normal, visual, select and operator-pending (same as plain 'map')";

            visualOnly = mapOptions "visual only";
            operator = mapOptions "operator-pending";
            insertCommand = mapOptions "insert and command-line";
            lang = mapOptions "insert, command-line and lang-arg";
            command = mapOptions "command-line";
          };
        };
        default = {};
        description = ''
          Custom keybindings for any mode.

          For plain maps (e.g. just 'map' or 'remap') use maps.normalVisualOp.
        '';

        example = ''
          maps = {
            normal."<leader>m" = {
              silent = true;
              action = "<cmd>make<CR>";
            }; # Same as nnoremap <leader>m <silent> <cmd>make<CR>
          };
        '';
      };
    };
  };

  config = let
    filterNonNull = mappings: filterAttrs (_name: value: value != null) mappings;
    globalsScript =
      mapAttrsFlatten (name: value: "let g:${name}=${valToVim value}")
      (filterNonNull cfg.globals);

    toLuaBindings = mode: maps:
      map (value: ''
        vim.keymap.set(${toLuaObject mode}, ${toLuaObject value.key}, ${toLuaObject value.action}, ${toLuaObject value.config})
      '') (genMaps mode maps);

    # I'm not sure if every one of these will work.
    allmap = toLuaBindings "" config.vim.maps.normalVisualOp;
    nmap = toLuaBindings "n" config.vim.maps.normal;
    vmap = toLuaBindings "v" config.vim.maps.visual;
    xmap = toLuaBindings "x" config.vim.maps.visualOnly;
    smap = toLuaBindings "s" config.vim.maps.select;
    imap = toLuaBindings "i" config.vim.maps.insert;
    cmap = toLuaBindings "c" config.vim.maps.command;
    tmap = toLuaBindings "t" config.vim.maps.terminal;
    lmap = toLuaBindings "l" config.vim.maps.lang;
    omap = toLuaBindings "o" config.vim.maps.operator;
    icmap = toLuaBindings "ic" config.vim.maps.insertCommand;

    resolveDag = {
      name,
      dag,
      mapResult,
    }: let
      # When the value is a string, default it to dag.entryAnywhere
      finalDag = mapAttrs (_: value:
        if isString value
        then entryAnywhere value
        else value)
      dag;
      sortedDag = topoSort finalDag;
      result =
        if sortedDag ? result
        then mapResult sortedDag.result
        else abort ("Dependency cycle in ${name}: " + toJSON sortedDag);
    in
      result;
  in {
    vim = {
      startPlugins = map (x: x.package) (attrValues cfg.extraPlugins);
      configRC = {
        globalsScript = entryAnywhere (concatStringsSep "\n" globalsScript);

        luaScript = let
          mkSection = r: ''
            -- SECTION: ${r.name}
            ${r.data}
          '';
          mapResult = r: (wrapLuaConfig (concatStringsSep "\n" (map mkSection r)));
          luaConfig = resolveDag {
            name = "lua config script";
            dag = cfg.luaConfigRC;
            inherit mapResult;
          };
        in
          entryAfter ["globalsScript"] luaConfig;

        extraPluginConfigs = let
          mkSection = r: ''
            -- SECTION: ${r.name}
            ${r.data}
          '';
          mapResult = r: (wrapLuaConfig (concatStringsSep "\n" (map mkSection r)));
          extraPluginsDag = mapAttrs (_: {
            after,
            setup,
            ...
          }:
            entryAfter after setup)
          cfg.extraPlugins;
          pluginConfig = resolveDag {
            name = "extra plugins config";
            dag = extraPluginsDag;
            inherit mapResult;
          };
        in
          entryAfter ["luaScript"] pluginConfig;

        # This is probably not the right way to set the config. I'm not sure how it should look like.
        mappings = let
          maps = [
            nmap
            imap
            vmap
            xmap
            smap
            cmap
            omap
            tmap
            lmap
            icmap
            allmap
          ];
          mapConfig = wrapLuaConfig (concatStringsSep "\n" (map (v: concatStringsSep "\n" v) maps));
        in
          entryAfter ["globalsScript"] mapConfig;
      };

      builtConfigRC = let
        failedAssertions = map (x: x.message) (filter (x: !x.assertion) config.assertions);

        baseSystemAssertWarn =
          if failedAssertions != []
          then throw "\nFailed assertions:\n${concatStringsSep "\n" (map (x: "- ${x}") failedAssertions)}"
          else showWarnings config.warnings;

        mkSection = r: ''
          " SECTION: ${r.name}
          ${r.data}
        '';
        mapResult = r: (concatStringsSep "\n" (map mkSection r));
        vimConfig = resolveDag {
          name = "vim config script";
          dag = cfg.configRC;
          inherit mapResult;
        };
      in
        baseSystemAssertWarn vimConfig;
    };
  };
}
