{lib, ...}: let
  inherit (lib.options) mkEnableOption mkOption literalExpression literalMD;
  inherit (lib.types) listOf lines;
  inherit (lib.nvim.types) pluginType;
in {
  options.vim.snippets.luasnip = {
    enable = mkEnableOption "luasnip";
    providers = mkOption {
      type = listOf pluginType;
      default = ["friendly-snippets"];
      description = ''
        The snippet provider packages.

        ::: {.note}
        These are simply appended to `vim.startPlugins`.
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
  };
}
