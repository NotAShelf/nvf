<div align="center"><p>
    <a href="https://github.com/NotAShelf/neovim-flake/releases/latest">
      <img alt="Latest release" src="https://img.shields.io/github/v/release/NotAShelf/neovim-flake?style=for-the-badge&logo=nixos&color=C9CBFF&logoColor=D9E0EE&labelColor=302D41" />
    </a>
    <a href="https://github.com/NotAShelf/neovim-flake/blob/main/LICENSE">
      <img alt="License" src="https://img.shields.io/github/license/NotAShelf/neovim-flake?style=for-the-badge&logo=nixos&color=ee999f&logoColor=D9E0EE&labelColor=302D41" />
    </a>
    <a href="https://github.com/NotAShelf/neovim-flake/stargazers">
      <img alt="Stars" src="https://img.shields.io/github/stars/NotAShelf/neovim-flake?style=for-the-badge&logo=nixos&color=c69ff5&logoColor=D9E0EE&labelColor=302D41" />
    </a>
    <a href="https://github.com/NotAShelf/neovim-flake/issues">
      <img alt="Issues" src="https://img.shields.io/github/issues/NotAShelf/neovim-flake?style=for-the-badge&logo=bilibili&color=F5E0DC&logoColor=D9E0EE&labelColor=302D41" />
    </a>
    <a href="https://github.com/NotAShelf/neovim-flake">
      <img alt="Repo Size" src="https://img.shields.io/github/repo-size/NotAShelf/neovim-flake?color=%23DDB6F2&label=SIZE&logo=codesandbox&style=for-the-badge&logoColor=D9E0EE&labelColor=302D41" />
    </a>

  <p align="center">
    <img src="https://stars.medv.io/NotAShelf/neovim-flake.svg", title="commits"/>
  </p>

An Nix wrapped IDE layer for the superior text editor, Neovim.

---

**[<kbd> <br> Install <br> </kbd>][Install]** 
**[<kbd> <br> Configure <br> </kbd>][Configure]** 
**[<kbd> <br> Documentation <br> </kbd>][Documentation]** 
**[<kbd> <br> Contribute <br> </kbd>][Contribute]** 
**[<kbd> <br> FAQ <br> </kbd>][Faq]**

[Contribute]: #contributing
[Install]: #install
[Configure]: #configure
[Documentation]: #documentation
[FAQ]: #faq

---

A highly configurable nix flake for Neovim, packing everything you might need to create your own neovim IDE.

## Install

### Using `nix`

The easiest way to install is to use the `nix profile` command. To install the default configuration, run:

```console
nix run github:notashelf/neovim-flake
```

The package exposes `.#nix` as the default output. You may use `.#nix`, `.#tidal` or `.#maximal` to get different configurations.

It is as simply as changing the target output to get a different configuration. For example, to get a configuration with `tidal` support, run:

```console
nix run github:notashelf/neovim-flake#tidal
```

Similar instructions will apply for `nix profile install`.

### On NixOS

NixOS users may add this repo to their flake inputs as such:

```nix
{
  inputs = {
    # point at this repository, you may pin specific revisions or branches while using `github:`
    neovim-flake.url = "github:notashelf/neovim-flake";
    
    # you may override our nixpkgs with your own, this will save you some cache hits and s recommended
    nixpkgs.follows = "nixpkgs"; 
  };
}
```

Then, you can use the `neovim-flake` input in your `systemPackages` or `home.packages`.

## Configure

TODO (awaiting #1 to be merged, which implements a separate configuration file)

## Documentation

See the [neovim-flake Manual](https://notashelf.github.io/neovim-flake/) for detailed documentation, available options, and release notes.
If you want to dive right into trying **neovim-flake** you can get a fully featured configuration with `nix` language support by running:

```console
nix run github:notashelf/neovim-flake
```

The documentation is scarce right now as a result of the ongoing rebase and refactor, but shall be available once more soon.

## Help

You can create an issue on the [issue tracker](issues) to ask questions or report bugs. I am not yet on spaces like matrix or IRC, so please use the issue tracker for now.

## Philosophy

The philosophy behind this flake configuration is to create an easily configurable and reproducible Neovim environment. While it does sacrifice in size
(which I know some users will find *disagreeable*), it offers a lot of flexibility and customizability in exchange for the large size of the flake inputs.
The KISS (Keep it simple, stupid) principle has been abandoned here, but you can ultimately declare a configuration that follows KISS.
For it is very easy to bring your own plugins and configurations. Whether you are a developer, writer, or live coder (see tidal cycles below!),
quickly craft a config that suits every project's need. Think of it like a distribution of Neovim that takes advantage of pinning vim plugins and
third party dependencies (such as tree-sitter grammars, language servers, and more).

One should never get a broken config when setting options. If setting multiple options results in a broken Neovim, file an issue! Each plugin knows when another plugin which allows for smart configuration of keybindings and automatic setup of things like completion sources and languages.

## Credits

This configuration is based on a few other configurations, including:

- [@sioodmy's](https://github.com/sioodmy) [dotfiles](https://github.com/sioodmy/dotfiles)
- [@wiltaylor's](https://github.com/wiltaylor) [neovim-flake](https://github.com/wiltaylor/neovim-flake)
- [@jordanisaacs's](https://github.com/jordanisaacs) [neovim-flake](https://github.com/jordanisaacs/neovim-flake)
- [@gvolpe's](https://github.com/gvolpe) [neovim-flake](https://github.com/gvolpe/neovim-flake)

I am grateful for their work and inspiration.

## FAQ

**Q**: Why is this flake so big?

**A**: I have sacrificed in size in order to provide a highly configurable and reproducible Neovim environment. A binary cache is provided to 
eleminate the need to build the flake from source, but it is still a large flake. If you do not need all the features, you can use the default `nix` output
instead of the `maximal` output. This will reduce size by a lot, but you will lose some language specific features.

**Q**: Will you use a plugin manager?

**A**: No. If you feel the need to ask that question, then you have missed the whole point of using nix and ultimately this flake. We load plugins with raw lua.

---
