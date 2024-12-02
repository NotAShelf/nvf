# Try it out {#ch-try-it-out}

Thanks to the portability of Nix, you can try out nvf without actually
installing it to your machine. Below are the commands you may run to try out
different configurations provided by this flake. As of v0.5, two specialized
configurations are provided:

- **Nix** - Nix language server + simple utility plugins
- **Maximal** - Variable language servers + utility and decorative plugins

You may try out any of the provided configurations using the `nix run` command
on a system where Nix is installed.

```bash
$ cachix use nvf                   # Optional: it'll save you CPU resources and time
$ nix run github:notashelf/nvf#nix # will run the default minimal configuration
```

Do keep in mind that this is **susceptible to garbage collection** meaning it
will be removed from your Nix store once you garbage collect.

## Using Prebuilt Configs {#sec-using-prebuilt-configs}

```bash
$ nix run github:notashelf/nvf#nix
$ nix run github:notashelf/nvf#maximal
```

### Available Configs {#sec-available-configs}

#### Nix {#sec-configs-nix}

`Nix` configuration by default provides LSP/diagnostic support for Nix alongside
a set of visual and functional plugins. By running `nix run .#`, which is the
default package, you will build Neovim with this config.

#### Maximal {#sec-configs-maximal}

`Maximal` is the ultimate configuration that will enable support for more
commonly used language as well as additional complementary plugins. Keep in
mind, however, that this will pull a lot of dependencies.

::: {.tip}

You are _strongly_ recommended to use the binary cache if you would like to try
the Maximal configuration.

:::
