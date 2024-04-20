{
  config,
  lib,
  ...
}: let
  inherit (builtins) map mapAttrs toJSON filter;
  inherit (lib.options) mkOption mkEnableOption literalMD literalExpression;
  inherit (lib.attrsets) filterAttrs getAttrs attrValues attrNames;
  inherit (lib.strings) optionalString isString concatStringsSep;
  inherit (lib.misc) mapAttrsFlatten;
  inherit (lib.trivial) showWarnings;
  inherit (lib.types) bool str oneOf attrsOf nullOr attrs submodule lines listOf either path;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.types) dagOf;
  inherit (lib.nvim.dag) entryAnywhere entryAfter topoSort mkLuarcSection mkVimrcSection;
  inherit (lib.nvim.lua) toLuaObject wrapLuaConfig listToLuaTable;
  inherit (lib.nvim.vim) valToVim;
  inherit (lib.nvim.config) mkBool;

  cfg = config.vim;

  # Most of the keybindings code is highly inspired by pta2002/nixvim.
  # Thank you!
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
    vim = {
      enableLuaLoader = mkEnableOption ''
        the experimental Lua module loader to speed up the start up process
      '';

      additionalRuntimePaths = mkOption {
        type = listOf (either path str);
        default = [];
        example = literalExpression ''
          [
            "~/.config/nvim-extra" # absolute path, as a string - impure
            ./nvim # relative path, as a path - pure
          ]
        '';
        description = ''
          Additional runtime paths that will be appended to the
          active runtimepath of the Neovim. This can be used to
          add additional lookup paths for configs, plugins, spell
          languages and other things you would generally place in
          your `$HOME/.config/nvim`.

          This is meant as a declarative alternative to throwing
          files into `~/.config/nvim` and having the Neovim
          wrapper pick them up. For more details on
          `vim.o.runtimepath`, and what paths to use; please see
          [the official documentation](https://neovim.io/doc/user/options.html#'runtimepath')
        '';
      };

      globals = mkOption {
        default = {};
        type = attrs;
        description = "Set containing global variable values";
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

          For plain maps (e.g. just 'map' or 'remap') use `maps.normalVisualOp`.
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

      configRC = mkOption {
        type = oneOf [(dagOf lines) str];
        default = {};
        description = ''
          Contents of vimrc, either as a string or a DAG.

          If this option is passed as a DAG, it will be resolved
          according to the DAG resolution rules (e.g. entryBefore
          or entryAfter) as per the neovim-flake library.
        '';

        example = literalMD ''
          ```vim
          " Set the tab size to 4 spaces
          set tabstop=4
          set shiftwidth=4
          set expandtab
          ```
        '';
      };

      luaConfigPre = mkOption {
        type = str;
        default = ''
          ${optionalString (cfg.additionalRuntimePaths != []) ''
            -- The following list is generated from `vim.additionalRuntimePaths`
            -- and is used to append additional runtime paths to the
            -- `runtimepath` option.
            local additionalRuntimePaths = ${listToLuaTable cfg.additionalRuntimePaths};

            for _, path in ipairs(additionalRuntimePaths) do
              vim.opt.runtimepath:append(path)
            end
          ''}

          ${optionalString cfg.enableLuaLoader "vim.loader.enable()"}
        '';

        defaultText = literalMD ''
          By default, this option will **append** paths in
          [vim.additionalRuntimePaths](#opt-vim.additionalRuntimePaths)
          to the `runtimepath` and enable the experimental Lua module loader
          if [vim.enableLuaLoader](#opt-vim.enableLuaLoader) is set to true.
        '';

        description = literalMD ''
          Verbatim lua code that will be inserted **before**
          the result of `luaConfigRc` DAG has been resolved.

          This option **does not** take a DAG set, but a string
          instead. Useful when you'd like to insert contents
          of lua configs after the DAG result.

          ::: {.warning}
          You do not want to override this option. It is used
          internally to set certain options as early as possible
          and should be avoided unless you know what you're doing.
          :::
        '';
      };

      luaConfigRC = mkOption {
        type = oneOf [(dagOf lines) str];
        default = {};
        description = ''
          Lua configuration, either as a string or a DAG.

          If this option is passed as a DAG, it will be resolved
          according to the DAG resolution rules (e.g. entryBefore
          or entryAfter) as per the neovim-flake library.
        '';

        example = literalMD ''
          ```lua
          -- Set the tab size to 4 spaces
          vim.opt.tabstop = 4
          vim.opt.shiftwidth = 4
          vim.opt.expandtab = true
          ```
        '';
      };

      luaConfigPost = mkOption {
        type = str;
        default = "";
        description = ''
          Verbatim lua code that will be inserted after
          the result of the `luaConfigRc` DAG has been resolved

          This option **does not** take a DAG set, but a string
          instead. Useful when you'd like to insert contents
          of lua configs after the DAG result.
        '';
      };

      builtConfigRC = mkOption {
        internal = true;
        type = lines;
        description = "The built config for neovim after resolving the DAG";
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

        # wrap the lua config in a lua block
        # using the wrapLuaConfic function from the lib
        luaScript = let
          mapResult = result: (wrapLuaConfig {
            luaBefore = "${cfg.luaConfigPre}";
            luaConfig = concatStringsSep "\n" (map mkLuarcSection result);
            luaAfter = "${cfg.luaConfigPost}";
          });

          luaConfig = resolveDag {
            name = "lua config script";
            dag = cfg.luaConfigRC;
            inherit mapResult;
          };
        in
          entryAfter ["globalsScript"] luaConfig;

        extraPluginConfigs = let
          mapResult = result: (wrapLuaConfig {
            luaConfig = concatStringsSep "\n" (map mkLuarcSection result);
          });

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
          mapConfig = wrapLuaConfig {luaConfig = concatStringsSep "\n" (map (v: concatStringsSep "\n" v) maps);};
        in
          entryAfter ["globalsScript"] mapConfig;
      };

      builtConfigRC = let
        # Catch assertions and warnings
        # and throw for each failed assertion. If no assertions are found, show warnings.
        failedAssertions = map (x: x.message) (filter (x: !x.assertion) config.assertions);
        baseSystemAssertWarn =
          if failedAssertions != []
          then throw "\nFailed assertions:\n${concatStringsSep "\n" (map (x: "- ${x}") failedAssertions)}"
          else showWarnings config.warnings;

        mapResult = result: (concatStringsSep "\n" (map mkVimrcSection result));
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
