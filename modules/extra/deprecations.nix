{lib, ...}: let
  inherit (lib.modules) mkRemovedOptionModule mkRenamedOptionModule;
in {
  imports = [
    # 2024-06-06
    (mkRemovedOptionModule ["vim" "tidal"] ''
      Tidalcycles language support has been removed as of 2024-06-06 as it was long unmaintained. If
      you depended on this functionality, please open an issue.
    '')

    # 2024-07-20
    (mkRemovedOptionModule ["vim" "lsp" "nvimCodeActionMenu"] ''
      nvimCodeActionMenu has been deprecated and removed upstream. As of 0.7, fastaction will be
      available under `vim.ui.fastaction` as a replacement. Simply remove everything under
      `vim.lsp.nvimCodeActionMenu`, and set `vim.ui.fastaction.enable` to `true`.
    '')

    (mkRemovedOptionModule ["vim" "autopairs" "enable"] ''
      vim.autopairs.enable has been removed in favor of per-plugin modules.
      You can enable nvim-autopairs with vim.autopairs.nvim-autopairs.enable instead.
    '')
    (mkRemovedOptionModule ["vim" "autopairs" "type"] ''
      vim.autopairs.type has been removed in favor of per-plugin modules.
      You can enable nvim-autopairs with vim.autopairs.nvim-autopairs.enable instead.
    '')
    (mkRemovedOptionModule ["vim" "autocomplete" "enable"] ''
      vim.autocomplete.enable has been removed in favor of per-plugin modules.
      You can enable nvim-cmp with vim.autocomplete.nvim-cmp.enable instead.
    '')
    (mkRemovedOptionModule ["vim" "autocomplete" "type"] ''
      vim.autocomplete.type has been removed in favor of per-plugin modules.
      You can enable nvim-cmp with vim.autocomplete.nvim-cmp.enable instead.
    '')
    (mkRemovedOptionModule ["vim" "snippets" "vsnip" "enable"] ''
      vim.snippets.vsnip.enable has been removed in favor of the more modern luasnip.
    '')
    (mkRenamedOptionModule ["vim" "lsp" "lspkind" "mode"] ["vim" "lsp" "lspkind" "setupOpts" "mode"])
  ];
}
