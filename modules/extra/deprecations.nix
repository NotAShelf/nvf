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

    # 2024-10-14
    (mkRemovedOptionModule ["vim" "configRC"] ''
      Please migrate your configRC sections to Neovim's Lua format, and
      add them to `vim.luaConfigRC`.

      See the v0.7 release notes for more information on why and how to
      migrate your existing configurations to the new format.
    '')

    (mkRemovedOptionModule ["vim" "disableDefaultRuntimePaths"] ''
      Nvf now uses $NVIM_APP_NAME so there is no longer the problem of
      (accidental) leaking of user configuration.
    '')
  ];
}
