<div align="center">
    <img src="assets/nvf-logo-work.svg" alt="nvf Logo"  width="200">
    <br/>
    <h1>nvf</h1>
</div>

<div align="center">
  <p>
    <a href="https://github.com/NotAShelf/nvf/releases/latest">
      <img alt="Latest release" src="https://img.shields.io/github/v/release/NotAShelf/nvf?style=for-the-badge&logo=nixos&color=C9CBFF&logoColor=D9E0EE&labelColor=302D41" />
    </a>
    <a href="https://github.com/NotAShelf/nvf/pulse">
      <img alt="Last commit" src="https://img.shields.io/github/last-commit/NotAShelf/nvf?style=for-the-badge&logo=starship&color=8bd5ca&logoColor=D9E0EE&labelColor=302D41"/>
    </a>
    <a href="https://github.com/NotAShelf/nvf/blob/main/LICENSE">
      <img alt="License" src="https://img.shields.io/github/license/NotAShelf/nvf?style=for-the-badge&logo=nixos&color=ee999f&logoColor=D9E0EE&labelColor=302D41" />
    </a>
    <a href="https://github.com/NotAShelf/nvf/stargazers">
      <img alt="Stars" src="https://img.shields.io/github/stars/NotAShelf/nvf?style=for-the-badge&logo=nixos&color=c69ff5&logoColor=D9E0EE&labelColor=302D41" />
    </a>
    <a href="https://github.com/NotAShelf/nvf/issues">
      <img alt="Issues" src="https://img.shields.io/github/issues/NotAShelf/nvf?style=for-the-badge&logo=bilibili&color=F5E0DC&logoColor=D9E0EE&labelColor=302D41" />
    </a>
    <a href="https://github.com/NotAShelf/nvf">
      <img alt="Repo Size" src="https://img.shields.io/github/repo-size/NotAShelf/nvf?color=%23DDB6F2&label=SIZE&logo=codesandbox&style=for-the-badge&logoColor=D9E0EE&labelColor=302D41" />
    </a>
  </p>
</div>

<p align="center">
    <img src="https://stars.medv.io/NotAShelf/nvf.svg", title="stars"/>
</p>

<div align="center">
  <a>
    nvf is a highly modular, configurable, extensible and easy to use Neovim configuration
    in Nix. Designed for flexibility and ease of use, nvf allows you to easily configure
    your fully featured Neovim instance with a few lines of Nix.
  </a>
</div>

---

<div align="center"><p>

[Features]: #features
[Get Started]: #get-started
[Documentation]: #documentation
[Help]: #help
[Contribute]: #contributing
[FAQ]: #frequently-asked-questions
[Credits]: #credits

**[<kbd><br> Features <br></kbd>][Features]**
**[<kbd><br> Get Started <br></kbd>][Get Started]**
**[<kbd><br> Documentation <br></kbd>][Documentation]**
**[<kbd><br> Help <br></kbd>][Help]**
**[<kbd><br> Contribute <br></kbd>][Contribute]**
**[<kbd><br> FAQ <br></kbd>][FAQ]** **[<kbd><br> Credits <br></kbd>][Credits]**

</p></div>

---

## Features

[standalone]: https://notashelf.github.io/nvf/index.xhtml#ch-standalone-installation
[NixOS module]: https://notashelf.github.io/nvf/index.xhtml#ch-standalone-nixos
[Home-Manager module]: https://notashelf.github.io/nvf/index.xhtml#ch-standalone-hm

- **Simple**: One language to rule them all! Use Nix to configure everything,
  with additional Lua Support
- **Reproducible**: Your configuration will behave the same _anywhere_. No
  surprises, promise!
- **Portable**: nvf depends _solely_ on your Nix store, and nothing else. No
  more global binaries! Works on all platforms, without hassle.
  - Options to install [standalone], [NixOS module] or [Home-Manager module].
- **Customizable**: There are _almost no defaults_ to annoy you. nvf is fully
  customizable through the Nix module system.
- Not comfortable with a full-nix config or want to bring your Lua config? You
  can do just that, no unnecessary restrictions.
- **Well-documented**: Documentation is priority. You will _never_ face
  undocumented, obscure behaviour.
- **Idiomatic**: nvf does things ✨ _the right way_ ✨ - the codebase is, and
  will, remain maintainable for myself and any contributors.

## Get Started

[nvf manual]: https://notashelf.github.io/nvf/
[issue tracker]: https://github.com/NotAShelf/nvf/issues

If you are not sold on the concepts of **nvf**, and would like to try out the
default configuration before even _thinking about_ installing it, you may run
the following in order to take **nvf** out for a spin.

```bash
# Run the default package
nix run github:notashelf/nvf
```

This will get you a feel for the base configuration and UI design. Though, none
of the configuration options are final as **nvf** is designed to be modular and
configurable.

> [!TIP]
> The flake exposes `#nix` as the default package, providing minimal language
> support and various utilities. You may also use the `#nix` or `#maximal`
> packages provided by the this flake to get try out different configurations.

It is as simple as changing the target output to get a different configuration.
For example, to get a configuration with large language coverage, run:

```bash
# Run the maximal package
nix run github:notashelf/nvf#maximal
```

Similar instructions will apply for `nix profile install`. However, you are
recommended to instead use the module system as described in the manual.

> [!NOTE]
> The `maximal` configuration is quite large, and might take a while to build.
> To get a feel for the configuration, use the default `nix` configuration.
> Should you choose to try out the `maximal` configuration, using the binary
> cache as described in the manual is _strongly_ recommended.

If you are convinced, proceed to the next section to view the installation
instructions.

## Documentation

### Installation

The _recommended_ way of installing nvf is using either the NixOS or the
Home-Manager module, though it is completely possible and no less supported to
install **nvf** as a standalone package, or a flake output.

See the rendered [nvf manual] for detailed and up-to-date installation guides,
configurations, available options, release notes and more. Tips for installing
userspace plugins is also contained in the documentation.

> [!TIP]
> While using NixOS or Home-Manager modules,
> `programs.nvf.enableManpages = true;` will allow you to view option
> documentation from the comfort of your terminal via `man 5 nvf`. The more you
> know.

Please create an issue on the [issue tracker] if you find the documentation
lacking or confusing. Any improvements to the documentation through pull
requests are also welcome, and appreciated.

## Getting Help

If you are confused, stuck or would like to ask a simple question; you may
create an issue on the [issue tracker] to ask questions or report bugs.

We are not not yet on spaces like matrix or IRC, so please use the issue tracker
for now.

## Contributing

I am always looking for new ways to help improve this flake. If you would like
to contribute, please read the [contributing guide](CONTRIBUTING.md) before
submitting a pull request. You can also create an issue on the [issue tracker]
before submitting a pull request if you would like to discuss a feature or bug
fix.

## Frequently Asked Questions

[appropriate issue template]: https://github.com/NotAShelf/nvf/issues/new/choose
[list of branches]: https://github.com/NotAShelf/nvf/branches
[list of open pull requests]: https://github.com/NotAShelf/nvf/pulls

**Q**: What platforms are supported?
<br/> **A**: nvf actively supports Linux and Darwin platforms using standalone
Nix, NixOS or Home-Manager. Please take a look at the [nvf manual] for available
installation instructions.

**Q**: Can you add _X_?
<br/> **A**: Maybe! It is not one of our goals to support each and every Neovim
plugin, however, I am always open to new modules and plugin setup additions to
**nvf**. Use the [appropriate issue template] and I will consider a module
addition. As mentioned before, pull requests to add new features are also
welcome.

**Q**: A plugin I need is not available in **nvf**. What to do?
<br/> **A**: **nvf** exposes several APIs for you to be able to add your own
plugin configurations! Please see the documentation on how you may do this.

**Q**: Main branch is awfully silent, is the project dead?
<br/> **A**: No! Sometimes we branch out (e.g. `v0.6`) to avoid breaking
userspace and work in a separate branch until we make sure the new additions are
implemented in the most comfortable way possible for the end user. If you have
not noticed any activity on the main branch, consider taking a look at the
[list of branches] or the [list of open pull requests]. You may also consider
_testing_ those release branches to get access to new features ahead of time and
better prepare to breaking changes.

## Credits

### Contributors

[mnw]: https://github.com/gerg-l/mnw

nvf would not be what it is today without the awesome people below. Special,
heart-felt thanks to

- [@fufexan](https://github.com/fufexan) - For the transition to flake-parts and
  invaluable Nix assistance.
- [@FlafyDev](https://github.com/FlafyDev) - For getting home-manager module to
  work and Nix assistance.
- [@n3oney](https://github.com/n3oney) - For making custom keybinds finally
  possible, and other module additions.
- [@horriblename](https://github.com/horriblename) - For actively implementing
  planned features and quality of life updates.
- [@Yavko](https://github.com/Yavko) - For the amazing **nvf** logo
- [@FrothyMarrow](https://github.com/FrothyMarrow) - For seeing mistakes that I
  could not.
- [@Diniamo](https://github.com/Diniamo) - For actively submitting pull
  requests, issues and assistance with maintenance of nvf.
- [@Gerg-l](https://github.com/gerg-l) - For the modern Neovim wrapper, [mnw],
  and occasional code improvements.

and everyone who has submitted issues or pull requests!

### Inspiration

This configuration borrows from and is based on a few other configurations,
including:

- [@jordanisaacs's](https://github.com/jordanisaacs)
  [neovim-flake](https://github.com/jordanisaacs/neovim-flake) that this flake
  is originally based on.
- [@sioodmy's](https://github.com/sioodmy)
  [dotfiles](https://github.com/sioodmy/dotfiles) that inspired the design
  choices for UI and plugin defaults.
- [@wiltaylor's](https://github.com/wiltaylor)
  [neovim-flake](https://github.com/wiltaylor/neovim-flake) for plugin and
  design ideas.
- [@gvolpe's](https://github.com/gvolpe)
  [neovim-flake](https://github.com/gvolpe/neovim-flake) for plugin, design and
  nix concepts.

I am grateful for their previous work and inspiration, and I wholeheartedly
recommend checking their work out.
<br/>

## License

Following the license of the
[original neovim-flake](https://github.com/jordanisaacs/neovim-flake), nvf has
been made available under the [**MIT License**](LICENSE). However, all assets
and documentation are published under the
[**CC BY License**](https://github.com/NotAShelf/nvf/blob/main/.github/assets/LICENSE)
under explicit permission by the artist.

<h6 align="center">Yes, this includes the logo work too. Stop taking artwork that is not yours!</h6>

---

<div align="right">
  <a href="#readme">Back to the Top</a>
</div>
