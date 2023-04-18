{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.autocomplete;
  lspkindEnabled = config.vim.lsp.enable && config.vim.lsp.lspkind.enable;
  builtSources =
    concatMapStringsSep
    "\n"
    (n: "{ name = '${n}'},")
    (attrNames cfg.sources);

  builtMaps =
    concatStringsSep
    "\n"
    (mapAttrsToList
      (n: v:
        if v == null
        then ""
        else "${n} = '${v}',")
      cfg.sources);

  dagPlacement =
    if lspkindEnabled
    then nvim.dag.entryAfter ["lspkind"]
    else nvim.dag.entryAnywhere;
in {
  options.vim = {
    autocomplete = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "enable autocomplete";
      };

      type = mkOption {
        type = types.enum ["nvim-cmp"];
        default = "nvim-cmp";
        description = "Set the autocomplete plugin. Options: [nvim-cmp]";
      };

      sources = mkOption {
        description = nvim.nmd.asciiDoc ''
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
          description = nvim.nmd.asciiDoc ''
            The function used to customize the appearance of the completion menu.

            If <<opt-vim.lsp.lspkind.enable>> is true, then the function
            will be called before modifications from lspkind.

            Default is to call the menu mapping function.
          '';
          type = types.str;
          default = "nvim_cmp_menu_map";
          example = nvim.nmd.literalAsciiDoc ''
            [source,lua]
            ---
            function(entry, vim_item)
              return vim_item
            end
            ---
          '';
        };
      };
    };
  };
}
