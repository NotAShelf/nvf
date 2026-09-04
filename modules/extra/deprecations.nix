{lib, ...}: let
  inherit (lib.modules) mkRemovedOptionModule mkRenamedOptionModule;
  inherit (lib.lists) concatLists;
  inherit (lib.nvim.config) batchRenameOptions;
in {
  imports = concatLists [
    # 2026-07-28
    [
      (mkRenamedOptionModule ["vim" "languages" "json" "treesitter" "json5Package"] ["vim" "languages" "json5" "treesitter" "package"])
      (mkRenamedOptionModule ["vim" "languages" "json" "treesitter" "jsonPackage"] ["vim" "languages" "json" "treesitter" "package"])
    ]

    # 2026-08-07
    [
      (mkRenamedOptionModule ["vim" "languages" "lua" "lsp" "lazydev" "enable"] ["vim" "languages" "lua" "extensions" "lazydev" "enable"])
    ]

    # 2026-08-16
    [
      (mkRemovedOptionModule ["vim" "minimap" "codewindow" "enable"] ''
        Disabled, because it doesn't support tree-sitter main branch.
      '')
    ]

    # 2026-08-16
    [
      (mkRenamedOptionModule ["vim" "ui" "breadcrumbs" "enable"] ["vim" "statusline" "lualine" "integrations" "breadcrumbs" "nvim-navic" "enable"])
      (mkRenamedOptionModule ["vim" "ui" "breadcrumbs" "lualine" "winbar" "enable"] ["vim" "statusline" "lualine" "integrations" "breadcrumbs" "nvim-navic" "enable"])
      (mkRenamedOptionModule ["vim" "ui" "breadcrumbs" "lualine" "winbar" "alwaysRender"] ["vim" "statusline" "lualine" "integrations" "breadcrumbs" "nvim-navic" "alwaysRender"])
      (mkRenamedOptionModule ["vim" "ui" "breadcrumbs" "navbuddy" "enable"] ["vim" "statusline" "lualine" "integrations" "breadcrumbs" "navbuddy" "enable"])
    ]

    # 2026-08-23
    [
      (mkRemovedOptionModule ["vim" "spellcheck" "vim-dirtytalk" "enable"] ''
        Dirtytalk is unmaintained and no longer works.
      '')
    ]

    # 2026-09-04
    (batchRenameOptions
      ["vim" "statusline" "lualine"]
      ["vim" "statusline" "lualine" "setupOpts" "options"]
      {
        theme = "theme";
        componentSeparator = "component_separators";
        sectionSeparator = "section_separators";
        globalStatus = "globalstatus";
        refresh = "refresh";
        alwaysDivideMiddle = "always_divide_middle";
        ignoreFocus = "ignore_focus";
        disabledFiletypes = "disabled_filetypes";
      })
    [
      (mkRemovedOptionModule ["vim" "statusline" "lualine" "activeSection"]
        ''
          Please use `vim.statusline.lualine.setupOpts.sections` instead.
        '')
      (mkRemovedOptionModule ["vim" "statusline" "lualine" "extraActiveSection"]
        ''
          Please use `vim.statusline.lualine.setupOpts.sections` with mkDefault
          and mkAfter instead.
        '')

      (mkRemovedOptionModule ["vim" "statusline" "lualine" "inactiveSection"]
        ''
          Please use `vim.statusline.lualine.setupOpts.inactive_sections`
          instead.
        '')
      (mkRemovedOptionModule ["vim" "statusline" "lualine" "extraInactiveSection"]
        ''
          Please use `vim.statusline.lualine.setupOpts.inactive_sections`
          with mkDefault and mkAfter instead.
        '')
    ]

    [
      (mkRenamedOptionModule ["vim" "statusline" "lualine" "icons" "enable"] ["vim" "statusline" "lualine" "setupOpts" "options" "icons_enabled"])
    ]
  ];
}
