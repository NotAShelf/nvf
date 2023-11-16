{lib, ...}: let
  inherit (lib) mkEnableOption mkMappingOption mkOption types;
in {
  options.vim = {
    autocomplete = {
      enable = mkEnableOption "enable autocomplete" // {default = false;};

      mappings = {
        complete = mkMappingOption "Complete [nvim-cmp]" "<C-Space>";
        confirm = mkMappingOption "Confirm [nvim-cmp]" "<CR>";
        next = mkMappingOption "Next item [nvim-cmp]" "<Tab>";
        previous = mkMappingOption "Previous item [nvim-cmp]" "<S-Tab>";
        close = mkMappingOption "Close [nvim-cmp]" "<C-e>";
        scrollDocsUp = mkMappingOption "Scroll docs up [nvim-cmp]" "<C-d>";
        scrollDocsDown = mkMappingOption "Scroll docs down [nvim-cmp]" "<C-f>";
      };

      type = mkOption {
        type = types.enum ["nvim-cmp"];
        default = "nvim-cmp";
        description = "Set the autocomplete plugin. Options: [nvim-cmp]";
      };

      sources = mkOption {
        description = ''
          Attribute set of source names for nvim-cmp.

          If an attribute set is provided, then the menu value of
          `vim_item` in the format will be set to the value (if
          utilizing the `nvim_cmp_menu_map` function).

          Note: only use a single attribute name per attribute set
        '';
        type = with types; attrsOf (nullOr str);
        default = {};
        example = ''
          {nvim-cmp = null; buffer = "[Buffer]";}
        '';
      };

      formatting = {
        format = mkOption {
          description = ''
            The function used to customize the appearance of the completion menu.

            If [](#opt-vim.lsp.lspkind.enable) is true, then the function
            will be called before modifications from lspkind.

            Default is to call the menu mapping function.
          '';
          type = types.str;
          default = "nvim_cmp_menu_map";
          example = lib.literalMD ''
            ```lua
            function(entry, vim_item)
              return vim_item
            end
            ```
          '';
        };
      };
    };
  };
}
