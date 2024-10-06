{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.snippets.vsnip;
in {
  config = mkIf cfg.enable (mkMerge [
    {
      vim.startPlugins = ["vim-vsnip"];
    }

    (mkIf config.vim.autocomplete.nvim-cmp.enable {
      vim = {
        startPlugins = ["cmp-vsnip"];
        autocomplete.nvim-cmp = {
          sources = {"vsnip" = "[VSnip]";};
          setupOpts.snippet.expand = mkLuaInline ''
            function(args)
              vim.fn["vsnip#anonymous"](args.body)
            end
          '';
        };
      };
    })
  ]);
}
