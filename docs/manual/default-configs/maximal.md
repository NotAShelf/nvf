# Maximal {#sec-default-maximal}

```bash
$ nix run github:notashelf/nvf#maximal -- test.nix
```

It is the same fully configured Neovim as with the [Nix](#sec-default-nix)
configuration, but with every supported language enabled.

::: {.note} Running the maximal config will download _a lot_ of packages as it
is downloading language servers, formatters, and more. :::
