{lib, ...}: let
  inherit (lib.modules) mkRemovedOptionModule mkRenamedOptionModule;
  inherit (lib.lists) concatLists;
  inherit (lib.nvim.config) batchRenameOptions;

  renamedVimOpts = batchRenameOptions ["vim"] ["vim" "options"] {
    colourTerm = "termguicolors";
    mouseSupport = "mouse";
    cmdHeight = "cmdheight";
    updateTime = "updatetime";
    mapTimeout = "tm";
    cursorlineOpt = "cursorlineopt";
    splitBelow = "splitbelow";
    splitRight = "splitright";
    autoIndent = "autoindent";
    wordWrap = "wrap";
    showSignColumn = "signcolumn";
  };
in {
  imports = concatLists [
    [
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

      (mkRemovedOptionModule ["vim" "autocomplete" "sources"] ''
        vim.autocomplete.sources has been removed in favor of per-plugin modules.
        You can add nvim-cmp sources with vim.autocomplete.nvim-cmp.sources
        instead.
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

      (mkRemovedOptionModule ["vim" "lsp" "trouble" "mappings" "toggle"] ''
        With Trouble having so many different modes, and breaking changes
        upstream, it no longer makes sense, nor works, to toggle only Trouble.
      '')

      # 2024-11-30
      (mkRenamedOptionModule ["vim" "leaderKey"] ["vim" "globals" "mapleader"])

      (mkRemovedOptionModule ["vim" "tabWidth"] ''
        Previous behaviour of this option was confusing and undocumented. Please set
        `tabstop` and `shiftwidth` manually in `vim.options` or per-filetype in a
        `ftplugin` directory added to your runtime path.
      '')

      # 2024-12-02
      (mkRenamedOptionModule ["vim" "enableEditorconfig"] ["vim" "globals" "editorconfig"])
    ]

    # 2024-12-01
    # Migrated via batchRenameOptions. Further batch renames must be below this line.
    renamedVimOpts
  ];
}
