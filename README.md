# neovim-flake

A highly configurable nix flake for neovim, packing everything you might need to create your own neovim IDE.

## Documentation

See the [neovim-flake Manual](https://notashelf.github.io/neovim-flake/) for documentation, available options, and release notes.
If you want to dive right into trying neovim-flake you can get a fully featured configuration with `nix` language support by running:

```console
nix run github:notashelf/neovim-flake
```

The documentation is scarce right now as a result of the ongoing rebase and refactor, but shall be available once more soon. 

## Help

You can create an issue on the [issue tracker](issues) to ask questions or report bugs. I am not yet on spaces like matrix or IRC, so please use the issue tracker for now.

## Philosophy

The philosophy behind this flake configuration is to create an eaesily configurable and reproducible neovim environment. While it does sacrifice in size 
(which I know some users will find *disagreeable*), it offers a lot of flexibiity and configurability in exchange for the large size of the flake inputs.
The KISS (Keep it simple, stupid) principle has been abandoneed here, but you can ultimately declare a configuration that follows KISS.
For it is very easy to bring your own plugins and configurations. Whether you are a developer, writer, or live coder (see tidal cycles below!), 
quickly craft a config that suits every project's need. Think of it like a distribution of Neovim that takes advantage of pinning vim plugins and 
third party dependencies (such as tree-sitter grammars, language servers, and more).

One should never get a broken config when setting options. If setting multiple options results in a broken neovim, file an issue! Each plugin knows when another plugin which allows for smart configuration of keybindings and automatic setup of things like completion sources and languages.

## Credits

This configuration is based on a few other configurations, including:

- @sioodmy's [dotfiles](https://github.com/sioodmy/dotfiles)
- @wiltaylor's [neovim-flake](https://github.com/wiltaylor/neovim-flake)
- @jordanisaacs's [neovim-flake](https://github.com/jordanisaacs/neovim-flake)
- @gvolpe's [neovim-flake](https://github.com/gvolpe/neovim-flake)

I am grateful for their work and inspiration.

--- 
