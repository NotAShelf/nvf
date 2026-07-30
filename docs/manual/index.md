# Introduction {#nvf-manual}

Generated for nvf @NVF_VERSION@

## Preface {#ch-preface}

### What is nvf {#sec-what-is-it}

[Nix]: https://nixos.org

**nvf** is a highly modular, configurable, extensible and _easy to use_ Neovim
configuration framework built for and designed to be used with [Nix]. Boasting
flexibility, robustness and ease of use (among other positive traits), this
project allows you to configure a fully featured Neovim instance with a few
lines of Nix while leaving all kinds of doors open for integrating Lua in your
configurations _whether you are a beginner or an advanced user_.

## Try it Out {#ch-try-it-out}

Thanks to the portability of Nix, you can try out **nvf** without actually
installing it to your machine. Below are the commands you may run to try out
different configurations provided by this flake. As of v0.5, two specialized
configurations are provided:

- **Nix** (`packages.nix`) - Nix language server + simple utility plugins
- **Maximal** (`packages.maximal`) - Variable language servers + utility and
  decorative plugins

You may try out any of the provided configurations using the `nix run` command
on a system where Nix is installed.

```sh
# Add the nvf cache
$ cachix use nvf                   # Optional: it'll save you CPU resources and time

# Run the minimal configuration with the cache enabled
$ nix run github:notashelf/nvf#nix # Will run the default minimal configuration
```

Do keep in mind that this is **susceptible to garbage collection** meaning that
the built outputs will be removed from your Nix store once you garbage collect.

## Reference Configurations {#sec-reference-configs}

The nvf team, can't guarantee anything for community configurations. We highly
recommend to only use them as reference and build your own.

### NVF Bundled Configurations {#sec-available-configs}

> [!NOTE]
> The below configurations are provided for demonstration purposes, and are
> **not** designed to be installed as is. You may refer to the installation
> steps below and the helpful tips section for details on creating your own
> configurations.

<!-- markdownlint-disable MD014 -->

```bash
$ nix run github:notashelf/nvf#nix
$ nix run github:notashelf/nvf#maximal
```

<!-- markdownlint-enable MD014 -->

#### Nix {#sec-configs-nix}

`Nix` configuration by default provides LSP/diagnostic support for Nix alongside
a set of visual and functional plugins. By running `nix run .#`, which is the
default package, you will build Neovim with this config.

```bash
$ nix run github:notashelf/nvf#nix test.nix
# => This will open a file called `test.nix` with Nix LSP and syntax highlighting
```

This command will start Neovim with some opinionated plugin configurations, and
is designed specifically for Nix. The `nix` configuration lets you see how a
fully configured Neovim setup _might_ look like without downloading too many
packages or shell utilities.

#### Maximal {#sec-configs-maximal}

`Maximal` is the ultimate configuration that will enable support for more
commonly used language as well as additional complementary plugins. Keep in
mind, however, that this will pull a lot of dependencies.

```bash
$ nix run github:notashelf/nvf#maximal -- test.nix
# => This will open a file called `test.nix` with a variety of plugins available
```

It uses the same configuration template with the [Nix](#sec-configs-nix)
configuration, but supports many more languages, and enables more utility,
companion or fun plugins.

> [!WARNING]
> Running the maximal config will download _a lot_ of packages as it is
> downloading language servers, formatters, and more. If CPU time and bandwidth
> are concerns, please use the default package instead.

### Maintainer Configurations {#sec-maintainer-configs}

#### NotAShelf {#sec-maintainer-config-notashelf}

> or make an exception like "this guy made nvf" SURELY that's enough
>
> [NotAShelf](https://github.com/NotAShelf)

~~[Configuration]()~~

#### Horriblename {#sec-maintainer-config-horriblename}

> My config is a 1k lines, single-file abomination, I don't think you should
> learn from me. xD
>
> [@horriblename](https://github.com/horriblename)

[Configuration](https://github.com/horriblename/dots.nix/blob/master/modules/home/terminal/nvim/nvf.nix#L75)

#### Soliprem {#sec-maintainer-config-soliprem}

> sth like "Daily driver config from a filetree plugin hater (tree lover though,
> trees are great); also builds a few plugins from source since they weren't in
> nixpkgs, that's probably the quirkies part of my config"
>
> [@Soliprem](https://github.com/soliprem)

[Configuration](https://codeberg.org/Soliprem/nix-config/src/branch/main/export)

#### Snoweuph {#sec-maintainer-config-snoweuph}

> Daily driver configuration for everything I do, from work to recreational
> programming. It is minimal - just **my** minimal.
>
> [@Snoweuph](https://github.com/snoweuph)

[Configuration](https://git.euph.dev/Snoweuph/nvim)

### Community Configurations {#sec-community-configs}

Below is a list of community configurations we want to highlight for reference.

> [!NOTE]
> You want to see your configuration here? Send us an MR.

- [Configuration](https://git.vulpe.systems/vulpe-systems/nix/src/branch/main/neovim)
  > ew emacs
  >
  > [@dish](https://github.com/pyrox0)

## Installing nvf {#ch-installation}

<!-- markdownlint-disable MD051 -->

[module installation section]: #ch-module-installation

<!-- markdownlint-enable MD051 -->

There are multiple ways of installing **nvf** on your system. You may either
choose the standalone installation method, which does not depend on a module
system and may be done on any system that has the Nix package manager or the
appropriate modules for NixOS and Home Manager as described in the
[module installation section].

```{=include=}
installation/custom-configuration.md
installation/modules.md
```

```{=include=} chapters
lib.md
```
