# Try it out {#ch-try-it-out}

Thanks to the portability of Nix, you can try out neovim-flake without actually installing it to your machine.
Below are the commands you may run to try out different configurations provided by this flake. As of v0.5, three
configurations are provided:

- Nix
- Tidal
- Maximal

You may try out any of the provided configurations using the `nix run` command on a system where Nix is installed.

```console
$ cachix use neovim-flake # Optional: it'll save you CPU resources and time
$ nix run github:notashelf/neovim-flake#nix # will run the default minimal configuration
```

Do keep in mind that this is **susceptible to garbage collection** meaning it will be removed from your Nix store
once you garbage collect. If you wish to install neovim-flake, please take a look at
[custom-configuration](#ch-custom-configuration) or [home-manager](#ch-hm-module) sections for installation
instructions.

## Using Prebuilt Configs {#sec-using-prebuild-configs}

```console
$ nix run github:notashelf/neovim-flake#nix
$ nix run github:notashelf/neovim-flake#tidal
$ nix run github:notashelf/neovim-flake#maximal
```

### Available Configs {#sec-available-configs}

#### Nix {#sec-configs-nix}

`Nix` configuration by default provides LSP/diagnostic support for Nix alongisde a set of visual and functional plugins.
By running `nix run .`, which is the default package, you will build Neovim with this config.

#### Tidal {#sec-configs-tidal}

Tidal is an alternative config that adds vim-tidal on top of the plugins from the Nix configuration.

#### Maximal {#sec-configs-maximal}

`Maximal` is the ultimate configuration that will enable support for more commonly used language as well as additional
complementary plugins. Keep in mind, however, that this will pull a lot of dependencies.

You are _strongly_ recommended to use the binary cache if you would like to try the Maximal configuration.
