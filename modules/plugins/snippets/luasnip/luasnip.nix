{lib, ...}: let
  inherit (lib.options) mkEnableOption mkOption literalExpression literalMD;
  inherit (lib.types) listOf lines submodule str attrsOf;
  inherit (lib.nvim.types) pluginType mkPluginSetupOption;
in {
  options.vim.snippets.luasnip = {
    enable = mkEnableOption "luasnip";
    providers = mkOption {
      type = listOf pluginType;
      default = ["friendly-snippets"];
      description = ''
        The snippet provider packages.

        ::: {.note}
        These are simply appended to {option} `vim.startPlugins`.
        :::
      '';
      example = literalExpression "[\"vimPlugins.vim-snippets\"]";
    };
    loaders = mkOption {
      type = lines;
      default = "require('luasnip.loaders.from_vscode').lazy_load()";
      defaultText = literalMD ''
        ```lua
        require('luasnip.loaders.from_vscode').lazy_load()
        ```
      '';
      description = "Lua code used to load snippet providers.";
      example = literalMD ''
        ```lua
        require("luasnip.loaders.from_snipmate").lazy_load()
        ```
      '';
    };

    setupOpts = mkPluginSetupOption "LuaSnip" {
      enable_autosnippets = mkEnableOption "autosnippets";
    };

    customSnippets.snipmate = mkOption {
      type = attrsOf (
        listOf (submodule {
          options = {
            trigger = mkOption {
              type = str;
              description = ''
                The trigger used to activate this snippet.
              '';
            };
            description = mkOption {
              type = str;
              default = "";
              description = ''
                The description shown for this snippet.
              '';
            };
            body = mkOption {
              type = str;
              description = ''
                [LuaSnip Documentation]: https://github.com/L3MON4D3/LuaSnip#add-snippets
                The body of the snippet in SnipMate format (see [LuaSnip Documentation]).
              '';
            };
          };
        })
      );
      default = {};
      example = ''
        {
          all = [
            {
              trigger = "if";
              body = "if $1 else $2";
            }
          ];
          nix = [
            {
              trigger = "mkOption";
              body = '''
                mkOption {
                  type = $1;
                  default = $2;
                  description = $3;
                  example = $4;
                }
              ''';
            }
          ];
        }
      '';
      description = ''
        A list containing custom snippets in the SnipMate format to be loaded by LuaSnip.
      '';
    };
  };
}
