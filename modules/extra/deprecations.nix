{lib, ...}: let
  inherit (builtins) head;
  inherit (lib.modules) mkRemovedOptionModule mkRenamedOptionModule doRename;
  inherit (lib.lists) concatLists;
  inherit (lib.nvim.config) batchRenameOptions;
  inherit (lib.trivial) warn;

  renamedVimOpts = batchRenameOptions ["vim"] ["vim" "options"] {
    # 2024-12-01
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

    # 2025-02-07
    scrollOffset = "scrolloff";
  };

  mkRemovedLspOpt = lang: (mkRemovedOptionModule ["vim" "languages" lang "lsp" "opts"] ''
    `vim.languages.${lang}.lsp.opts` is now moved to `vim.lsp.servers.<server_name>.init_options`
  '');

  mkRemovedLspPackage = lang: (mkRemovedOptionModule ["vim" "languages" lang "lsp" "package"] ''
    `vim.languages.${lang}.lsp.package` is now moved to `vim.lsp.servers.<server_name>.cmd`
  '');

  mkRenamedLspServer = lang:
    doRename
    {
      from = ["vim" "languages" lang "lsp" "server"];
      to = ["vim" "languages" lang "lsp" "servers"];
      visible = false;
      warn = true;
      use = x:
        warn
        "Obsolete option `vim.languages.${lang}.lsp.server` used, use `vim.languages.${lang}.lsp.servers` instead."
        (head x);
    };

  mkRemovedFormatPackage = lang: (mkRemovedOptionModule ["vim" "languages" lang "format" "package"] ''
    `vim.languages.${lang}.format.package` is removed, please use `vim.formatter.conform-nvim.formatters.<formatter_name>.command` instead.
  '');

  mkRemovedEnumListOption = optionPath: removedValue: msg: {
    config,
    lib,
    ...
  }: let
    inherit (lib) elem attrByPath concatStringsSep;
  in {
    config.assertions = [
      {
        assertion = !(elem removedValue (attrByPath optionPath [] config));
        message = ''
          The value `${removedValue}` was removed from `${concatStringsSep "." optionPath}`.
          ${msg}
        '';
      }
    ];
  };
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
  ];
}
