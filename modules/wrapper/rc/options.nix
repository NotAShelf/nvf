{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkRemovedOptionModule;
  inherit (lib.options) mkOption mkEnableOption literalMD literalExpression;
  inherit (lib.strings) optionalString;
  inherit (lib.types) str attrs lines listOf either path bool;
  inherit (lib.nvim.types) dagOf;
  inherit (lib.nvim.lua) listToLuaTable;

  cfg = config.vim;
in {
  imports = [
    (mkRemovedOptionModule ["vim" "configRC"] ''
      Please migrate your configRC sections to Neovim's Lua format, and
      add them to luaConfigRC.

      See the v0.7 release notes for more information on how to migrate
      your existing configurations.
    '')
  ];

  options.vim = {
    enableLuaLoader = mkEnableOption ''
      the experimental Lua module loader to speed up the start up process

      If `true`, this will enable the experimental Lua module loader which:
        - overrides loadfile
        - adds the lua loader using the byte-compilation cache
        - adds the libs loader
        - removes the default Neovim loader

      This is disabled by default. Before setting this option, please
      take a look at the [{option}`official documentation`](https://neovim.io/doc/user/lua.html#vim.loader.enable()).
    '';

    disableDefaultRuntimePaths = mkOption {
      type = bool;
      default = true;
      example = false;
      description = ''
        Disables the default runtime paths that are set by Neovim
        when it starts up. This is useful when you want to have
        full control over the runtime paths that are set by Neovim.

        ::: {.note}
        To avoid leaking imperative user configuration into your
        configuration, this is enabled by default. If you wish
        to load configuration from user configuration directories
        (e.g. {file}`$HOME/.config/nvim`, {file}`$HOME/.config/nvim/after`
        and {file}`$HOME/.local/share/nvim/site`) you may set this
        option to true.
        :::
      '';
    };

    additionalRuntimePaths = mkOption {
      type = listOf (either path str);
      default = [];
      example = literalExpression ''
        [
          # absolute path, as a string - impure
          "$HOME/.config/nvim-extra"

          # relative path, as a path - pure
          ./nvim

          # source type path - pure and reproducible
          (builtins.source {
            path = ./runtime;
            name = "nvim-runtime";
          })
        ]
      '';

      description = ''
        Additional runtime paths that will be appended to the
        active runtimepath of the Neovim. This can be used to
        add additional lookup paths for configs, plugins, spell
        languages and other things you would generally place in
        your {file}`$HOME/.config/nvim`.

        This is meant as a declarative alternative to throwing
        files into {file}`~/.config/nvim` and having the Neovim
        wrapper pick them up. For more details on
        `vim.o.runtimepath`, and what paths to use; please see
        [the official documentation](https://neovim.io/doc/user/options.html#'runtimepath')
      '';
    };

    extraLuaFiles = mkOption {
      type = listOf (either path str);
      default = [];
      example = literalExpression ''
        [
          # absolute path, as a string - impure
          "$HOME/.config/nvim/my-lua-file.lua"

          # relative path, as a path - pure
          ./nvim/my-lua-file.lua

          # source type path - pure and reproducible
          (builtins.source {
            path = ./nvim/my-lua-file.lua;
            name = "my-lua-file";
          })
        ]
      '';

      description = ''
        Additional lua files that will be sourced by Neovim.
        Takes both absolute and relative paths, all of which
        will be called via the `luafile` command in Neovim.

        See [lua-commands](https://neovim.io/doc/user/lua.html#lua-commands)
        on the Neovim documentation for more details.

        ::: {.warning}
        All paths passed to this option must be valid. If Neovim cannot
        resolve the path you are attempting to sourcee, then your configuration
        will error, and Neovim will not start. Please ensure that all paths
        are correct before using this option.
        :::
      '';
    };

    globals = mkOption {
      type = attrs;
      default = {};
      example = {"some_variable" = 42;};
      description = ''
        An attribute set containing global variable values
        for storing vim variables as early as possible. If
        populated, this option will set vim variables in the
        built luaConfigRC as the first item.

        ::: {.note}
        `{foo = "bar";}` will set `vim.g.foo` to "bar", where
        the type of `bar` in the resulting Lua value will be
        inferred from the type of the value in the `{name = value;}`
        pair passed to the option.
        :::
      '';
    };

    options = mkOption {
      type = attrs;
      default = {};
      example = {visualbell = true;};
      description = ''
        An attribute set containing vim options to be set
        as early as possible. If populated, this option will
        set vim options in the built luaConfigRC after `basic`
        and before `pluginConfigs` DAG entries.

        ::: {.note}
        `{foo = "bar";}` will set `vim.o.foo` to "bar", where
        the type of `bar` in the resulting Lua value will be
        inferred from the type of the value in the`{name = value;}`
        pair passed to the option.
        :::
      '';
    };

    pluginRC = mkOption {
      type = either (dagOf lines) str;
      default = {};
      description = "The DAG used to configure plugins. If a string is passed, entryAnywhere is automatically applied.";
    };

    luaConfigPre = mkOption {
      type = str;
      default = ''
        ${optionalString (cfg.additionalRuntimePaths != []) ''
          -- The following list is generated from `vim.additionalRuntimePaths`
          -- and is used to append additional runtime paths to the
          -- `runtimepath` option.
          vim.opt.runtimepath:append(${listToLuaTable cfg.additionalRuntimePaths})
        ''}

        ${optionalString cfg.disableDefaultRuntimePaths ''
          -- Remove default user runtime paths from the
          -- `runtimepath` option to avoid leaking user configuration
          -- into the final neovim wrapper
          local defaultRuntimePaths = {
            vim.fn.stdpath('config'),              -- $HOME/.config/nvim
            vim.fn.stdpath('config') .. "/after",  -- $HOME/.config/nvim/after
            vim.fn.stdpath('data') .. "/site",     -- $HOME/.local/share/nvim/site
          }

          for _, path in ipairs(defaultRuntimePaths) do
            vim.opt.runtimepath:remove(path)
          end
        ''}

        ${optionalString cfg.enableLuaLoader "vim.loader.enable()"}
      '';

      defaultText = literalMD ''
        By default, this option will **append** paths in
        [](#opt-vim.additionalRuntimePaths)
        to the `runtimepath` and enable the experimental Lua module loader
        if [](#opt-vim.enableLuaLoader) is set to true.
      '';

      example = literalExpression ''"$${builtins.readFile ./my-lua-config-pre.lua}"'';

      description = ''
        Verbatim lua code that will be inserted **before**
        the result of `luaConfigRc` DAG has been resolved.

        This option **does not** take a DAG set, but a string
        instead. Useful when you'd like to insert contents
        of lua configs after the DAG result.

        ::: {.warning}
        You do not want to override this option with mkForce
        It is used internally to set certain options as early
        as possible and should be avoided unless you know what
        you're doing. Passing a string to this option will
        merge it with the default contents.
        :::
      '';
    };

    luaConfigRC = mkOption {
      type = either (dagOf lines) str;
      default = {};
      description = ''
        Lua configuration, either as a string or a DAG.

        If this option is passed as a DAG, it will be resolved
        according to the DAG resolution rules (e.g. entryBefore
        or entryAfter) as per the **nvf** extended library.
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
      example = literalExpression ''"$${builtins.readFile ./my-lua-config-post.lua}"'';
      description = ''
        Verbatim lua code that will be inserted **after**
        the result of the `luaConfigRc` DAG has been resolved

        This option **does not** take a DAG set, but a string
        instead. Useful when you'd like to insert contents
        of lua configs after the DAG result.
      '';
    };

    builtLuaConfigRC = mkOption {
      internal = true;
      type = lines;
      description = "The built lua config for neovim after resolving the DAG";
    };
  };
}
