# Frequently Asked Questions {#ch-faq}

[nvf manual]: ./index.md
[issue template]: https://github.com/NotAShelf/nvf/issues/new/choose

## Which platforms are supported?

**nvf** actively supports **Linux and Darwin** platforms using standalone Nix,
NixOS or Home-Manager. It has been reported that **Android** is also supported
through the Home-Manager module, or using standalone package. Please take a look
at the [nvf manual] for available installation instructions.

## Can you add _X_?

Maybe! It is not one of our goals to support each and every Neovim plugin,
however, I am always open to new modules and plugin setup additions to **nvf**.
Use the appropriate [issue template] and I will consider a module addition. As
mentioned before, pull requests to add new features are also welcome.

## A plugin I need is not available in **nvf**. What to do?

**nvf** exposes several APIs for you to be able to add your own plugin
configurations! Please see the
[documentation](./hacking.md#sec-additional-plugins) on how you may do this.

## Will you support non-flake installations?

Quite possibly. **nvf** started as "neovim-flake", which does mean it is and
will remain flakes-first but we might consider non-flakes compatibility. Though
keep in mind that **nvf** under non-flake environments would lose
customizability of plugin inputs, which is one of our primary features.

## I prefer working with Lua, can I use nvf as a plugin manager while I use an imperative path (e.g., `~/.config/nvim`) for my Neovim configuration instead of a configuration generated from Nix?

Yes! Add `"~/.config/nvim"` to `vim.additionalRuntimePaths = [ ... ]` and any
plugins you want to load to `vim.startPlugins`. This will load your
configuration from `~/.config/nvim`. You may still use `vim.*` options in Nix to
further configure Neovim.

## What release model does **nvf** use?

**nvf** primarily follows a rolling release model. The `main` branch tracks
unstable **nixpkgs** for most of the development cycle. Around major **nixpkgs**
releases, **nvf** enters a **pre-release phase**. During this time, `main`
temporarily tracks the corresponding stable **nixpkgs** branch to stabilize the
upcoming `YY.MM` release. After roughly one to two months, the release branch is
cut, `main` returns to unstable **nixpkgs**, and development of new features
continues there. The latest `YY.MM` release receives bug fixes and compatibility
updates, but no new features.
