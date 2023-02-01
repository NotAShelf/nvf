# neovim-flake

A highly configurable nix flake for neovim.

Come join the Matrix room if you have any questions or need help: [#neovim-flake:matrix.org](https://matrix.to/#/#neovim-flake:matrix.org)

## Documentation

See the [neovim-flake Manual](https://jordanisaacs.github.io/neovim-flake/) for documentation, available options, and release notes.

If you want to dive right into trying neovim-flake you can get a fully featured configuration with `nix` language support by running:

```
nix run github:jordanisaacs/neovim-flake
```

## Screenshot

![screenshot](./screenshot.png)

## Philosophy

The philosophy behind this flake configuration is to allow for easily configurable and reproducible neovim environments. Enter a directory and have a ready to go neovim configuration that is the same on every machine. Whether you are a developer, writer, or live coder (see tidal cycles below!), quickly craft a config that suits every project's need. Think of it like a distribution of Neovim that takes advantage of pinning vim plugins and third party dependencies (such as tree-sitter grammars, language servers, and more).

As a result, one should never get a broken config when setting options. If setting multiple options results in a broken neovim, file an issue! Each plugin knows when another plugin which allows for smart configuration of keybindings and automatic setup of things like completion sources and languages.


## Credit

Originally based on Wil Taylor's amazing [neovim-flake](https://github.com/wiltaylor/neovim-flake)
