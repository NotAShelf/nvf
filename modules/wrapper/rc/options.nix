{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption literalMD literalExpression;
  inherit (lib.strings) optionalString;
  inherit (lib.types) str oneOf attrs lines listOf either path bool;
  inherit (lib.nvim.types) dagOf;
  inherit (lib.nvim.lua) listToLuaTable;
  cfg = config.vim;
in {
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
        (e.g. `$HOME/.config/nvim`, `$HOME/.config/nvim/after`
        and `$HOME/.local/share/nvim/site`) you may set this
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

          # as a Neovim plugin - pure, reproducible and follows Neovim practices
          (pkgs.vimUtils.buildVimPlugin {
             pname = "nvim-runtime";
             src = ./nvim-runtime; # needs a plugin/init.lua, can refer to modules in a root level lua/ dir
             version = "#";
          })
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
      type = attrs;
      default = {};
      description = ''
        An attribute set containing global variable values
        for storing vim variables as early as possible. If
        populated, this soption will set vim variables in the
        built configRC as the first item.

        E.g. {foo = "bar"} will set `g:foo` to "bar" where
        the type of `bar` in the resulting vimscript will be
        infered from the type of the value in the `{name = value}`
        pair.
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

        ${optionalString cfg.disableDefaultRuntimePaths ''
          -- Remove default user runtime paths from the
          -- `runtimepath` option to avoid leaking user configuration
          -- into the final neovim wrapper
          local defaultRuntimePaths = {}
          local function addPath(path)
              table.insert(defaultRuntimePaths, path)
              table.insert(defaultRuntimePaths, path .. "/site")
          end

          -- Add standard paths to the table
          addPath(vim.fn.stdpath('config')) -- $XDG_CONFIG_HOME
          addPath(vim.fn.stdpath('data'))   -- $XDG_DATA_HOME
          addPath(vim.fn.stdpath('state'))  -- $XDG_STATE_HOME
          addPath(vim.fn.stdpath('cache'))  -- $XDG_CACHE_HOME

          -- Remove paths that are already in runtimepath
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
      example = literalExpression ''"$${builtins.readFile ./my-lua-config-post.lua}"'';
      description = ''
        Verbatim lua code that will be inserted **after**
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
}
