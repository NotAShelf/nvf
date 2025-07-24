# Keybinds {#sec-keybinds}

As of 0.4, there exists an API for writing your own keybinds and a couple of
useful utility functions are available in the
[extended standard library](https://github.com/NotAShelf/nvf/tree/main/lib). The
following section contains a general overview to how you may utilize said
functions.

## Custom Key Mappings Support for a Plugin {#sec-custom-key-mappings}

To set a mapping, you should define it in `vim.keymaps`.

An example, simple keybinding, can look like this:

```nix
{
  vim.keymaps = [
    {
      key = "<leader>wq";
      mode = ["n"];
      action = ":wq<CR>";
      silent = true;
      desc = "Save file and quit";
    }
  ];
}
```

There are many settings available in the options. Please refer to the
[documentation](https://notashelf.github.io/nvf/options.html#opt-vim.keymaps) to
see a list of them.

**nvf** provides a helper function, so that you don't have to write the
mapping attribute sets every time:

- `mkKeymap`, which mimics neovim's `vim.keymap.set` function

You can read the source code of some modules to see them in action, but the
usage should look something like this:

```nix
# plugindefinition.nix
{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.binds) mkMappingOption;
in {
  options.vim.plugin = {
    enable = mkEnableOption "Enable plugin";

    # Mappings should always be inside an attrset called mappings
    mappings = {
      workspaceDiagnostics = mkMappingOption config.vim.enableNvfKeymaps "Workspace diagnostics [trouble]" "<leader>lwd";
      documentDiagnostics = mkMappingOption config.vim.enableNvfKeymaps "Document diagnostics [trouble]" "<leader>ld";
      lspReferences = mkMappingOption config.vim.enableNvfKeymaps "LSP References [trouble]" "<leader>lr";
      quickfix = mkMappingOption config.vim.enableNvfKeymaps "QuickFix [trouble]" "<leader>xq";
      locList = mkMappingOption config.vim.enableNvfKeymaps "LOCList [trouble]" "<leader>xl";
      symbols = mkMappingOption config.vim.enableNvfKeymaps "Symbols [trouble]" "<leader>xs";
    };
}
```

```nix
# config.nix
{
  config,
  lib,
  options,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.binds) mkKeymap;

  cfg = config.vim.plugin;

  keys = cfg.mappings;
  inherit (options.vim.lsp.trouble) mappings;
in {
  config = mkIf cfg.enable {
    vim.keymaps = [
      (mkKeymap "n" keys.workspaceDiagnostics "<cmd>Trouble toggle diagnostics<CR>" {desc = mappings.workspaceDiagnostics.description;})
      (mkKeymap "n" keys.documentDiagnostics "<cmd>Trouble toggle diagnostics filter.buf=0<CR>" {desc = mappings.documentDiagnostics.description;})
      (mkKeymap "n" keys.lspReferences "<cmd>Trouble toggle lsp_references<CR>" {desc = mappings.lspReferences.description;})
      (mkKeymap "n" keys.quickfix "<cmd>Trouble toggle quickfix<CR>" {desc = mappings.quickfix.description;})
      (mkKeymap "n" keys.locList "<cmd>Trouble toggle loclist<CR>" {desc = mappings.locList.description;})
      (mkKeymap "n" keys.symbols "<cmd>Trouble toggle symbols<CR>" {desc = mappings.symbols.description;})
    ];
  };
}
```

::: {.note}

If you have come across a plugin that has an API that doesn't seem to easily
allow custom keybindings, don't be scared to implement a draft PR. We'll help
you get it done.

:::
