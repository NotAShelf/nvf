{lib, ...}: let
  inherit (lib.options) mkOption literalMD literalExpression;
  inherit (lib.types) str bool int enum attrsOf lines listOf either path submodule anything;
  inherit (lib.nvim.types) dagOf;
in {
  options.vim = {
    enableLuaLoader = mkOption {
      type = bool;
      default = false;
      example = true;
      description = ''
        [official documentation]: https://neovim.io/doc/user/lua.html#vim.loader.enable()

        Whether to enable the experimental Lua module loader to speed up the start
        up process. If `true`, this will enable the experimental Lua module loader
        which:

        * overrides loadfile
        * adds the lua loader using the byte-compilation cache
        * adds the libs loader
        * removes the default Neovim loader

        ::: {.note}
        The Lua module loader is *disabled* by default. Before setting this option, please
        take a look at the {option}`[official documentation]`. This option may be enabled by
        default in the future.
        :::
      '';
    };

    additionalRuntimePaths = mkOption {
      type = listOf (either path str);
      default = [];
      example = literalExpression ''
        [
          # Absolute path, as a string. This is the impure option.
          "$HOME/.config/nvim-extra"

          # Relative path inside your configuration. If your config
          # is version controlled, then this is pure and reproducible.
          ./nvim

          # Source type path. This pure and reproducible.
          # See `:doc builtins.path` inside a Nix repl for more options.
          (builtins.path {
            path = ./runtime; # this must be a relative path
            name = "nvim-runtime"; # name is arbitrary
          })
        ]
      '';

      description = ''
        Additional runtime paths that will be appended to the active
        runtimepath of the Neovim. This can be used to add additional
        lookup paths for configs, plugins, spell languages and other
        things you would generally place in your {file}`$HOME/.config/nvim`.

        This is meant as a declarative alternative to throwing files into
        {file}`~/.config/nvim` and having the Neovim wrapper pick them up.

        For more details on `vim.o.runtimepath`, and what paths to use, please see
        [the official documentation](https://neovim.io/doc/user/options.html#'runtimepath').
      '';
    };

    extraLuaFiles = mkOption {
      type = listOf (either path str);
      default = [];
      example = literalExpression ''
        [
          # Absolute path, as a string - impure
          "$HOME/.config/nvim/my-lua-file.lua"

          # Relative path, as a path - pure
          ./nvim/my-lua-file.lua

          # Source type path - pure and reproducible
          (builtins.path {
            path = ./nvim/my-lua-file.lua;
            name = "my-lua-file";
          })
        ]
      '';

      description = ''
        Additional Lua files that will be sourced by Neovim.

        Takes both absolute and relative paths, all of which will be called
        via the `luafile` command in Neovim.

        See [lua-commands](https://neovim.io/doc/user/lua.html#lua-commands)
        on the Neovim documentation for more details.

        ::: {.warning}
        All paths passed to this option must be valid. If Neovim cannot
        resolve the path you are attempting to source, then your configuration
        will error, and Neovim will not start. Please ensure that all paths
        are correct before using this option.
        :::
      '';
    };

    globals = mkOption {
      default = {};
      type = submodule {
        freeformType = attrsOf anything;
        options = {
          mapleader = mkOption {
            type = str;
            default = " ";
            description = "The key used for `<leader>` mappings";
          };

          maplocalleader = mkOption {
            type = str;
            default = ",";
            description = "The key used for `<localleader>` mappings";
          };

          editorconfig = mkOption {
            type = bool;
            default = true;
            description = ''
              Whether to enable EditorConfig integration in Neovim.

              This defaults to true as it is enabled by default in stock
              Neovim, setting this option to false disables EditorConfig
              integration entirely.

              See [Neovim documentation](https://neovim.io/doc/user/editorconfig.html)
              for more details on configuring EditorConfig behaviour.
            '';
          };
        };
      };

      example = {"some_variable" = 42;};
      description = ''
        A freeform attribute set containing global variable values for setting vim
        variables as early as possible. If populated, this option will set vim variables
        in the built {option}`luaConfigRC` as the first item.

        ::: {.note}
        `{foo = "bar";}` will set `vim.g.foo` to "bar", where the type of `bar` in the
        resulting Lua value will be inferred from the type of the value in the
        `{name = value;}` pair passed to the option.
        :::
      '';
    };

    options = mkOption {
      default = {};
      type = submodule {
        freeformType = attrsOf anything;
        options = {
          termguicolors = mkOption {
            type = bool;
            default = true;
            description = "Set terminal up for 256 colours";
          };

          mouse = mkOption {
            type = str;
            default = "nvi";
            example = "a";
            description = ''
              Set modes for mouse support.

              * n - normal
              * v - visual
              * i - insert
              * c - command-line
              * h - all modes when editing a help file
              * a - all modes
              * r - for hit-enter and more-prompt prompt

              [neovim documentation]: https://neovim.io/doc/user/options.html#'mouse'"

              This option takes a string to ensure proper conversion to the corresponding Lua type.
              As such, we do not check the value passed to this option. Please ensure that any value
              that is set here is a valid value as per [neovim documentation].
            '';
          };

          cmdheight = mkOption {
            type = int;
            default = 1;
            description = "Height of the command pane";
          };

          updatetime = mkOption {
            type = int;
            default = 300;
            description = "The number of milliseconds till Cursor Hold event is fired";
          };

          tm = mkOption {
            type = int;
            default = 500;
            description = "Timeout in ms that Neovim will wait for mapped action to complete";
          };

          cursorlineopt = mkOption {
            type = enum ["line" "screenline" "number" "both"];
            default = "line";
            description = "Highlight the text line of the cursor with CursorLine hl-CursorLine";
          };

          splitbelow = mkOption {
            type = bool;
            default = true;
            description = "New splits will open below instead of on top";
          };

          splitright = mkOption {
            type = bool;
            default = true;
            description = "New splits will open to the right";
          };

          autoindent = mkOption {
            type = bool;
            default = true;
            description = "Enable auto indent";
          };

          wrap = mkOption {
            type = bool;
            default = true;
            description = "Enable word wrapping.";
          };

          signcolumn = mkOption {
            type = str;
            default = "yes";
            example = "no";
            description = "Whether to show the sign column";
          };

          tabstop = mkOption {
            type = int;
            default = 8; # Neovim default
            description = ''
              Number of spaces that a `<Tab>` in the file counts for. Also see
              the {command}`:retab` command, and the {option}`softtabstop` option.
            '';
          };

          shiftwidth = mkOption {
            type = int;
            default = 8; # Neovim default
            description = ''
              Number of spaces to use for each step of (auto)indent. Used for
              {option}`cindent`, `>>`, `<<`, etc.

              When zero the {option}`tabstop` value will be used.
            '';
          };
        };
      };

      example = {visualbell = true;};
      description = ''
        A freeform attribute set containing vim options to be set as early as possible.
        If populated, this option will set vim options in the built {option}`luaConfigRC`
        after `basic` and before `pluginConfigs` DAG entries.

        ::: {.note}
        `{foo = "bar";}` will set `vim.o.foo` to "bar", where the type of `bar` in the
        resulting Lua value will be inferred from the type of the value in the
        `{name = value;}` pair passed to the option.
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
      default = "";
      defaultText = literalMD ''
        By default, this option will **append** paths in
        {option}`vim-additionalRuntimePaths`
        to the `runtimepath` and enable the experimental Lua module loader
        if {option}`vim.enableLuaLoader` is set to true.
      '';

      example = literalExpression "\${builtins.readFile ./my-lua-config-pre.lua}";

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
      example = literalExpression "\${builtins.readFile ./my-lua-config-post.lua}";
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
