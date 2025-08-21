# Try it out {#ch-try-it-out}

Thanks to the portability of Nix, you can try out nvf without actually
installing it to your machine. Below are the commands you may run to try out
different configurations provided by this flake. As of v0.5, two specialized
configurations are provided:

- **Nix** (`packages.nix`) - Nix language server + simple utility plugins
- **Maximal** (`packages.maximal`) - Variable language servers + utility and
  decorative plugins

You may try out any of the provided configurations using the `nix run` command
on a system where Nix is installed.

```sh
$ cachix use nvf                   # Optional: it'll save you CPU resources and time
$ nix run github:notashelf/nvf#nix # Will run the default minimal configuration
```

Do keep in mind that this is **susceptible to garbage collection** meaning that
the built outputs will be removed from your Nix store once you garbage collect.

## Using Prebuilt Configs {#sec-using-prebuilt-configs}

```bash
$ nix run github:notashelf/nvf#nix
$ nix run github:notashelf/nvf#maximal
```

### Available Configurations {#sec-available-configs}

::: {.info}

The below configurations are provided for demonstration purposes, and are
**not** designed to be installed as is. You may

#### Nix {#sec-configs-nix}

`Nix` configuration by default provides LSP/diagnostic support for Nix alongside
a set of visual and functional plugins. By running `nix run .#`, which is the
default package, you will build Neovim with this config.

```bash
$ nix run github:notashelf/nvf#nix test.nix
```

This command will start Neovim with some opinionated plugin configurations, and
is designed specifically for Nix. the `nix` configuration lets you see how a
fully configured Neovim setup _might_ look like without downloading too many
packages or shell utilities.

#### Maximal {#sec-configs-maximal}

`Maximal` is the ultimate configuration that will enable support for more
commonly used language as well as additional complementary plugins. Keep in
mind, however, that this will pull a lot of dependencies.

```bash
$ nix run github:notashelf/nvf#maximal -- test.nix
```

It uses the same configuration template with the [Nix](#sec-configs-nix)
configuration, but supports many more languages, and enables more utility,
companion or fun plugins.

::: {.warning}

Running the maximal config will download _a lot_ of packages as it is
downloading language servers, formatters, and more. If CPU time and bandwidth
are concerns, please use the default package instead.

:::
