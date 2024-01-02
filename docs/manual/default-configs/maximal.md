# Maximal {#sec-default-maximal}

```bash
$ nix shell github:notashelf/neovim-flake#maximal test.nix
```

It is the same fully configured neovim as with the [Nix](#sec-default-nix) config, but with every supported language enabled.

:::{.note}

Running the maximal config will download _a lot_ of packages as it is downloading language servers, formatters, and more.

:::
