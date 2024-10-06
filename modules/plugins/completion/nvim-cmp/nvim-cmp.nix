{
  lib,
  config,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption literalExpression literalMD;
  inherit (lib.types) str attrsOf nullOr;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.binds) mkMappingOption;
  inherit (lib.nvim.types) mkPluginSetupOption luaInline;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.autocomplete.nvim-cmp;
in {
  options.vim.autocomplete.nvim-cmp = {
    enable = mkEnableOption "nvim-cmp" // {default = false;};
    setupOpts = mkPluginSetupOption "the autocomplete plugin" {
      completion.completeopt = mkOption {
        type = str;
        default = "menu,menuone,noinsert";
        description = ''
          A comma-separated list of options for completion.

          See `:help completeopt` for the complete list.
        '';
      };
    };

    mappings = {
      complete = mkMappingOption "Complete [nvim-cmp]" "<C-Space>";
      confirm = mkMappingOption "Confirm [nvim-cmp]" "<CR>";
      next = mkMappingOption "Next item [nvim-cmp]" "<Tab>";
      previous = mkMappingOption "Previous item [nvim-cmp]" "<S-Tab>";
      close = mkMappingOption "Close [nvim-cmp]" "<C-e>";
      scrollDocsUp = mkMappingOption "Scroll docs up [nvim-cmp]" "<C-d>";
      scrollDocsDown = mkMappingOption "Scroll docs down [nvim-cmp]" "<C-f>";
    };

    format = mkOption {
      type = luaInline;
      default = mkLuaInline ''
        function(entry, vim_item)
          vim_item.menu = (${toLuaObject cfg.sources})[entry.source.name]
          return vim_item
        end
      '';
      defaultText = literalMD ''
        ```lua
        function(entry, vim_item)
          vim_item.menu = (''${toLuaObject config.vim.autocomplete.nvim-cmp.sources})[entry.source.name]
          return vim_item
        end
        ```
      '';
      description = ''
        The function used to customize the completion menu entires.
        This is outside of `setupOpts` because of internal reasons.

        See `:help cmp-config.formatting.format`.
      '';
    };

    sources = mkOption {
      type = attrsOf (nullOr str);
      default = {};
      description = "The list of sources used by nvim-cmp";
      example = literalExpression ''
        {
          nvim-cmp = null;
          buffer = "[Buffer]";
        }
      '';
    };
  };
}
