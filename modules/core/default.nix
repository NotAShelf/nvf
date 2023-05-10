{
  config,
  lib,
  ...
}:
with lib;
with builtins; let
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
      type = types.bool;
      default = value;
      description = description;
    };

  # Most of the keybindings code is highly inspired by pta2002/nixvim. Thank you!
  mapConfigOptions = {
    silent =
      mkBool false
      (nvim.nmd.asciiDoc "Whether this mapping should be silent. Equivalent to adding <silent> to a map.");

    nowait =
      mkBool false
      (nvim.nmd.asciiDoc "Whether to wait for extra input on ambiguous mappings. Equivalent to adding <nowait> to a map.");

    script =
      mkBool false
      (nvim.nmd.asciiDoc "Equivalent to adding <script> to a map.");

    expr =
      mkBool false
      (nvim.nmd.asciiDoc "Means that the action is actually an expression. Equivalent to adding <expr> to a map.");

    unique =
      mkBool false
      (nvim.nmd.asciiDoc "Whether to fail if the map is already defined. Equivalent to adding <unique> to a map.");

    noremap =
      mkBool true
      "Whether to use the 'noremap' variant of the command, ignoring any custom mappings on the defined action. It is highly advised to keep this on, which is the default.";

    desc = mkOption {
      type = types.nullOr types.str;
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
        filterAttrs (n: v: v != null)
        (getAttrs (attrNames mapConfigOptions) action);
    in {
      config =
        if config == {}
        then {"__empty" = null;}
        else config;
      action =
        if action.lua
        then {"__raw" = action.action;}
        else action.action;
    };
  in
    builtins.attrValues (builtins.mapAttrs
      (key: action: let
        normalizedAction = normalizeAction action;
      in {
        inherit (normalizedAction) action config;
        key = key;
        mode = mode;
      })
      maps);

  mapOption = types.submodule {
    options =
      mapConfigOptions
      // {
        action = mkOption {
          type = types.str;
          description = "The action to execute.";
        };

        lua = mkOption {
          type = types.bool;
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
      type = types.attrsOf mapOption;
      default = {};
    };
in {
  options.vim = {
    viAlias = mkOption {
      description = "Enable vi alias";
      type = types.bool;
      default = true;
    };

    vimAlias = mkOption {
      description = "Enable vim alias";
      type = types.bool;
      default = true;
    };

    configRC = mkOption {
      description = "vimrc contents";
      type = nvim.types.dagOf types.lines;
      default = {};
    };

    luaConfigRC = mkOption {
      description = "vim lua config";
      type = nvim.types.dagOf types.lines;
      default = {};
    };

    builtConfigRC = mkOption {
      internal = true;
      type = types.lines;
      description = "The built config for neovim after resolving the DAG";
    };

    startPlugins = nvim.types.pluginsOpt {
      default = [];
      description = "List of plugins to startup.";
    };

    optPlugins = nvim.types.pluginsOpt {
      default = [];
      description = "List of plugins to optionally load";
    };

    globals = mkOption {
      default = {};
      description = "Set containing global variable values";
      type = types.attrs;
    };

    maps = mkOption {
      type = types.submodule {
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

  config = let
    mkVimBool = val:
      if val
      then "1"
      else "0";
    valToVim = val:
      if (isInt val)
      then (builtins.toString val)
      else
        (
          if (isBool val)
          then (mkVimBool val)
          else (toJSON val)
        );

    filterNonNull = mappings: filterAttrs (_name: value: value != null) mappings;
    globalsScript =
      mapAttrsFlatten (name: value: "let g:${name}=${valToVim value}")
      (filterNonNull cfg.globals);

    toLuaObject = args:
      if builtins.isAttrs args
      then
        if hasAttr "__raw" args
        then args.__raw
        else if hasAttr "__empty" args
        then "{ }"
        else
          "{"
          + (concatStringsSep ","
            (mapAttrsToList
              (n: v:
                if head (stringToCharacters n) == "@"
                then toLuaObject v
                else "[${toLuaObject n}] = " + (toLuaObject v))
              (filterAttrs
                (
                  n: v:
                    !isNull v && (toLuaObject v != "{}")
                )
                args)))
          + "}"
      else if builtins.isList args
      then "{" + concatMapStringsSep "," toLuaObject args + "}"
      else if builtins.isString args
      then
        # This should be enough!
        builtins.toJSON args
      else if builtins.isPath args
      then builtins.toJSON (toString args)
      else if builtins.isBool args
      then "${boolToString args}"
      else if builtins.isFloat args
      then "${toString args}"
      else if builtins.isInt args
      then "${toString args}"
      else if isNull args
      then "nil"
      else "";

    toLuaBindings = mode: maps:
      builtins.map (value: ''
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
      sortedDag = nvim.dag.topoSort dag;
      result =
        if sortedDag ? result
        then mapResult sortedDag.result
        else abort ("Dependency cycle in ${name}: " + toJSON sortedConfig);
    in
      result;
  in {
    vim = {
      configRC = {
        globalsScript = nvim.dag.entryAnywhere (concatStringsSep "\n" globalsScript);

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
          nvim.dag.entryAfter ["globalsScript"] luaConfig;

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
          nvim.dag.entryAfter ["globalsScript"] mapConfig;
      };

      builtConfigRC = let
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
        vimConfig;
    };
  };
}
