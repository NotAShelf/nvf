# Extended Library {#ch-lib}

nvf exposes utility functions under `inputs.nvf.lib` that are used internally
and available for use in your own flake modules.

## Accessing the Library {#sec-lib-access}

Two entry points are available:

- **`inputs.nvf.lib.nvim`**: the nvf utility library, containing all
  sub-namespaces described below.
- **`inputs.nvf.lib.neovimConfiguration`**: the main function for building a
  standalone Neovim derivation from a set of nvf modules (see
  [installation](#ch-installation)).

Example usage in a flake:

```nix
{
  inputs.nvf.url = "github:notashelf/nvf";

  outputs = { nvf, ... }: {
    packages.x86_64-linux.neovim =
      (nvf.lib.neovimConfiguration {
        pkgs = import nixpkgs { system = "x86_64-linux"; };
        modules = [ ./nvf-config.nix ];
      }).neovim;
  };
}
```

## Sub-namespaces {#sec-lib-namespaces}

### `lib.nvim.dag` {#sec-lib-dag}

DAG utilities for ordering configuration sections. Provides `entryAnywhere`,
`entryAfter`, `entryBefore`, `entryBetween`, and `topoSort`. Used internally to
order Lua configuration chunks and exposed for custom DAG entries via
`vim.luaConfigRC`.

### `lib.nvim.binds` {#sec-lib-binds}

Keybinding construction helpers. Provides `mkBinding`, `mkLuaBinding`,
`mkExprBinding`, `mkMappingOption`, `addDescriptionsToMappings`, `mkSetBinding`,
`mkSetLuaBinding`, `mkSetExprBinding`, `pushDownDefault`, and `mkKeymap`.

### `lib.nvim.lua` {#sec-lib-lua}

Nix-to-Lua conversion utilities. Provides `toLuaObject` for converting Nix
values to Lua literal strings, `isLuaInline` for detecting raw-Lua passthrough
values, and `luaTable` for building Lua table strings from lists of Lua
expressions.

### `lib.nvim.languages` {#sec-lib-languages}

Helpers for language module definitions. Provides `mkEnable` for boolean
language-feature options, `lspOptions` as a reusable submodule type for LSP
server configuration, and `diagnosticsToLua` for converting diagnostic provider
lists to DAG entries.

### `lib.nvim.lists` {#sec-lib-lists}

List utilities. Provides `listContainsValues` for checking that all values in
one list are present in another.

### `lib.nvim.attrsets` {#sec-lib-attrsets}

Attribute set utilities. Provides `mapListToAttrs` for mapping a list to an
attribute set via a `{ name; value }` mapping function.

<!--

TODO: do this with ndg, properly

## API Reference {#sec-lib-api-reference}

Type signatures and examples for all library functions are auto-generated from
source docstrings and available in the lib section of the HTML manual.

-->
