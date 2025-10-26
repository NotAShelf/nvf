{lib, ...}: let
  inherit (builtins) head warn;
  inherit (lib.modules) mkRemovedOptionModule mkRenamedOptionModule doRename;
  inherit (lib.lists) concatLists;
  inherit (lib.nvim.config) batchRenameOptions;

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

      # 2025-02-06
      (mkRemovedOptionModule ["vim" "disableArrows"] ''
        Top-level convenience options are now in the process of being removed from nvf as
        their behaviour was abstract, and confusing. Please use 'vim.options' or 'vim.luaConfigRC'
        to replicate previous behaviour.
      '')

      # 2025-04-04
      (mkRemovedOptionModule ["vim" "lsp" "lsplines"] ''
        lsplines module has been removed from nvf, as its functionality is now built into Neovim
        under the diagnostics module. Please consider using one of 'vim.diagnostics.config' or
        'vim.luaConfigRC' to configure LSP lines for Neovim through its own diagnostics API.
      '')

      # 2025-05-04
      (mkRemovedOptionModule ["vim" "useSystemClipboard"] ''
        Clipboard behaviour should now be controlled through the new, more fine-grained module
        interface found in 'vim.clipboard'. To replicate previous behaviour, you may either
        add 'vim.opt.clipboard:append("unnamedplus")' in luaConfigRC, or preferably set it
        in 'vim.clipboard.registers'. Please see the documentation for the new module for more
        details, or open an issue if you are confused.
      '')

      # 2025-07-12
      (mkRenamedLspServer "assembly")

      (mkRenamedLspServer "astro")
      (mkRemovedLspPackage "astro")

      (mkRenamedLspServer "bash")
      (mkRemovedLspPackage "bash")

      (mkRemovedLspOpt "clang")
      (mkRemovedLspPackage "clang")
      (mkRenamedLspServer "clang")

      (mkRemovedLspPackage "clojure")

      (mkRenamedLspServer "csharp")
      (mkRemovedLspPackage "csharp")

      (mkRenamedLspServer "css")
      (mkRemovedLspPackage "css")

      (mkRemovedLspPackage "cue")

      (mkRenamedLspServer "dart")
      (mkRemovedLspPackage "dart")
      (mkRemovedLspOpt "dart")

      (mkRenamedLspServer "elixir")
      (mkRemovedLspPackage "elixir")

      (mkRenamedLspServer "fsharp")
      (mkRemovedLspPackage "fsharp")

      (mkRenamedLspServer "gleam")
      (mkRemovedLspPackage "gleam")

      (mkRenamedLspServer "go")
      (mkRemovedLspPackage "go")

      (mkRemovedLspPackage "haskell")

      (mkRemovedLspPackage "hcl")

      (mkRenamedLspServer "helm")
      (mkRemovedLspPackage "helm")

      (mkRemovedLspPackage "java")

      (mkRenamedLspServer "julia")
      (mkRemovedLspPackage "julia")

      (mkRemovedLspPackage "kotlin")

      (mkRemovedLspPackage "lua")

      (mkRenamedLspServer "markdown")
      (mkRemovedLspPackage "markdown")

      (mkRenamedLspServer "nim")
      (mkRemovedLspPackage "nim")

      (mkRenamedLspServer "nix")
      (mkRemovedLspPackage "nix")
      (mkRemovedOptionModule ["vim" "languages" "nix" "lsp" "options"] ''
        `vim.languages.nix.lsp.options` has been moved to `vim.lsp.servers.<server_name>.init_options`.
      '')

      (mkRenamedLspServer "nu")
      (mkRemovedLspPackage "nu")

      (mkRenamedLspServer "ocaml")
      (mkRemovedLspPackage "ocaml")

      (mkRenamedLspServer "odin")
      (mkRemovedLspPackage "odin")

      (mkRenamedLspServer "php")
      (mkRemovedLspPackage "php")

      (mkRenamedLspServer "python")
      (mkRemovedLspPackage "python")

      (mkRenamedLspServer "r")
      (mkRemovedLspPackage "r")

      (mkRenamedLspServer "ruby")
      (mkRemovedLspPackage "ruby")

      (mkRenamedLspServer "sql")
      (mkRemovedLspPackage "sql")

      (mkRenamedLspServer "svelte")
      (mkRemovedLspPackage "svelte")

      (mkRenamedLspServer "tailwind")
      (mkRemovedLspPackage "tailwind")

      (mkRemovedLspPackage "terraform")

      (mkRenamedLspServer "ts")
      (mkRemovedLspPackage "ts")

      (mkRenamedLspServer "typst")
      (mkRemovedLspPackage "typst")

      (mkRenamedLspServer "vala")
      (mkRemovedLspPackage "vala")

      (mkRenamedLspServer "wgsl")
      (mkRemovedLspPackage "wgsl")

      (mkRenamedLspServer "yaml")
      (mkRemovedLspPackage "yaml")

      (mkRenamedLspServer "zig")
      (mkRemovedLspPackage "zig")

      # 2025-10-22
      (mkRenamedOptionModule ["vim" "languages" "rust" "crates" "enable"] ["vim" "languages" "rust" "extensions" "crates-nvim" "enable"])
      (mkRemovedOptionModule ["vim" "languages" "rust" "crates" "codeActions"] ''
        'vim.languages.rust.crates' option has been moved to 'vim.languages.rust.extensions.crates-nvim' in full and the
        codeActions option has been removed. To set up code actions again, you may use the the new 'setupOpts' option
        located under 'vim.languages.rust.extensions.crates-nvim'. Refer to crates.nvim documentation for setup steps:

        <https://github.com/Saecki/crates.nvim/wiki/Documentation-v0.7.1#in-process-language-server>
      '')
    ]

    # Migrated via batchRenameOptions. Further batch renames must be below this line.
    renamedVimOpts
  ];
}
