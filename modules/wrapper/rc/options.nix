{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption literalMD literalExpression;
  inherit (lib.strings) optionalString;
  inherit (lib.types) bool str oneOf attrsOf nullOr attrs submodule lines listOf either path;
  inherit (lib.nvim.types) dagOf;
  inherit (lib.nvim.lua) listToLuaTable;
  inherit (lib.nvim.config) mkBool;

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

  cfg = config.vim;
in {
  options.vim = {
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