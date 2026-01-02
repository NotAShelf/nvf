<!-- markdownlint-disable MD013 MD033 MD041-->
<div align="center">
    <img src=".github/assets/nvf-logo-work.svg" alt="nvf Logo"  width="192">
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
[Help]: #getting-help
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

[standalone]: https://nvf.notashelf.dev/#ch-standalone-installation
[NixOS module]: https://nvf.notashelf.dev/#ch-standalone-nixos
[Home-Manager module]: https://nvf.notashelf.dev/#ch-standalone-hm
[release notes]: https://notashelf.github.io/nvf/release-notes.html
[discussions tab]: https://github.com/notashelf/nvf/discussions
[FAQ section]: #frequently-asked-questions
[DAG]: https://en.wikipedia.org/wiki/Directed_acyclic_graph

- **Simple**: One language to rule them all! Use Nix to configure everything,
  with optional Lua support for robust configurability!
- **Reproducible**: Your configuration will behave the same _anywhere_. No
  surprises, promise!
- **Portable**: nvf depends _solely_ on your Nix store, and nothing else. No
  more global binaries! Works on all platforms, without hassle.
  - Options to install [standalone], [NixOS module] or [Home-Manager module].
- **Customizable**: There are _almost no defaults_ to annoy you. nvf is fully
  customizable through the Nix module system.
  - Not comfortable with a full-nix config or want to bring your Lua config? You
    can do just that, no unnecessary restrictions.
  - Lazyloading? We got it! Lazyload both internal and external plugins at will
    💤 .
  - nvf allows _ordering configuration bits_ using [DAG] (_Directed acyclic
    graph_)s. It has never been easier to construct an editor configuration
    deterministically!
  - nvf exposes everything you need to avoid a vendor lock-in. Which means you
    can add new modules, plugins and so on without relying on us adding a module
    for them! Though, of course, feel free to request them.
    - Use plugins from anywhere: inputs, npins, nixpkgs... You name it.
    - Add your own modules with ease. It's all built-in!
- **Well-documented**: Documentation is priority. You will _never_ face
  undocumented, obscure behaviour.
  - Any and all changes, breaking or otherwise, will be communicated in the
    [release notes].
  - Refer to the [FAQ section] for answers to common questions.
    - Your question not there? Head to the [discussions tab]!
- **Idiomatic**: nvf does things ✨ _the right way_ ✨ - the codebase is, and
  will, remain maintainable for myself and any contributors.
- **Community-Led**: we would like nvf to be fully capable of accomplishing what
  you really want it to do. If you have a use case that is not made possible by
  nvf, please open an issue (or a pull request!)
  - Your feedback is more than welcome! Feedback is what _drives_ nvf forward.
    If you have anything to say, or ask, please let us know.
  - Pull requests are _always_ welcome. If you think the project can benefit
    from something you did locally, but are not quite sure how to upstream,
    please feel free to contact us! We'll help you get it done.

## Get Started

[nvf manual]: https://notashelf.github.io/nvf/
[issue tracker]: https://github.com/NotAShelf/nvf/issues

If you are not sold on the concepts of **nvf**, and would like to try out the
default configuration before even _thinking about_ installing it, you may run
the following in order to take **nvf** out for a spin.

```bash
# Run the default package
$ nix run github:notashelf/nvf
```

This will get you a feel for the base configuration and UI design. Though, none
of the configuration options are final as **nvf** is designed to be modular and
configurable.

> [!TIP]
> The flake exposes `nix` as the default package, which will be evaluated when
> you run `nix build` or `nix run` on this repo. It is minimal, and providing
> limited language support and various utilities. We also expose the `maximal`
> package, which you may choose to build if you'd like to see more of nvf's
> built-in modules. Please keep in mind that those are demo packages, nvf does
> not ship a default configuration if installed as a NixOS/Home-Manager module
> or via standalone method.

It is as simple as changing the target output in your `nix run` command to get a
different configuration. For example, to get a configuration with large language
coverage, run:

```bash
# Run the maximal package
$ nix run github:notashelf/nvf#maximal
```

Similar instructions will apply for `nix profile install`. However, you are
recommended to instead use the module system as described in the [nvf manual].

> [!NOTE]
> The `maximal` configuration is quite large, and might take a while to build.
> To get a feel for the configuration, use the default `nix` configuration.
> Should you choose to try out the `maximal` configuration, using the binary
> cache as described in the manual is _strongly_ recommended.

If you are convinced, proceed to the next section to view the installation
instructions.

## Documentation

**nvf** prides itself in its rich, intuitive documentation. The chapter below
covers several methods through which you can install **nvf**. If you believe
something is missing, or could be done better, please feel free to contact us!

### Installation

The _recommended_ way of installing nvf is using either the NixOS or the
Home-Manager module, though it is completely possible and no less supported to
install **nvf** as a standalone package, or a flake output.

See the rendered [nvf manual] for detailed and up-to-date installation guides,
configurations, available options, release notes and more. Tips for installing
userspace plugins are also contained in the documentation.

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

We are not yet on spaces like matrix or IRC, so please use the issue tracker for
now. The [discussions tab] can also be a place to request help from community
members, or engage in productive discussion with the maintainers.

## Contributing

[contributing guide]: .github/CONTRIBUTING.md

I am always looking for new ways to help improve this flake. If you would like
to contribute, please read the [contributing guide] before submitting a pull
request. You can also create an issue on the [issue tracker] before submitting a
pull request if you would like to discuss a feature or bug fix.

## Frequently Asked Questions

[issue template]: https://github.com/NotAShelf/nvf/issues/new/choose
[list of branches]: https://github.com/NotAShelf/nvf/branches
[list of open pull requests]: https://github.com/NotAShelf/nvf/pulls

**Q**: What platforms are supported?

**A**: nvf actively supports **Linux and Darwin** platforms using standalone
Nix, NixOS or Home-Manager. It has been reported that **Android** is also
supported through the Home-Manager module, or using standalone package. Please
take a look at the [nvf manual] for available installation instructions.

**Q**: Can you add _X_?

**A**: Maybe! It is not one of our goals to support each and every Neovim
plugin, however, I am always open to new modules and plugin setup additions to
**nvf**. Use the appropriate [issue template] and I will consider a module
addition. As mentioned before, pull requests to add new features are also
welcome.

**Q**: A plugin I need is not available in **nvf**. What to do?

**A**: **nvf** exposes several APIs for you to be able to add your own plugin
configurations! Please see the documentation on how you may do this.

**Q**: Main branch is awfully silent, is the project dead?

**A**: No! Sometimes we branch out (e.g. `v0.6`) to avoid breaking userspace and
work in a separate branch until we make sure the new additions are implemented
in the most comfortable way possible for the end user. If you have not noticed
any activity on the main branch, consider taking a look at the
[list of branches] or the [list of open pull requests]. You may also consider
_testing_ those release branches to get access to new features ahead of time and
better prepare for breaking changes.

**Q**: Will you support non-flake installations?

**A**: Quite possibly. **nvf** started as "neovim-flake", which does mean it is
and will remain flakes-first but we might consider non-flakes compatibility.
Though keep in mind that **nvf** under non-flake environments would lose
customizability of plugin inputs, which is one of our primary features.

**Q**: I prefer working with Lua, can I use nvf as a plugin manager while I use
an imperative path (e.g., `~/.config/nvim`) for my Neovim configuration instead
of a configuration generated from Nix?

**A**: Yes! Add `"~/.config/nvim"` to `vim.additionalRuntimePaths = [ ... ]` and
any plugins you want to load to `vim.startPlugins`. This will load your
configuration from `~/.config/nvim`. You may still use `vim.*` options in Nix to
further configure Neovim.

## Credits

### Co-Maintainers

Alongside [myself](https://github.com/notashelf), nvf is developed by those
talented folk. **nvf** would not be what it is today without their invaluable
contributions.

- [**@horriblename**](https://github.com/horriblename)
  ([Liberapay](https://liberapay.com/horriblename/)) - For actively implementing
  planned features and quality of life updates.
- [**@Soliprem**](https://github.com/soliprem) - For rigorously implementing
  missing features and excellent work on new language modules.

Please do remember to extend your thanks (financially or otherwise) if this
project has been helpful to you.

### Contributors

[mnw]: https://github.com/gerg-l/mnw

nvf would not be what it is today without the awesome people below. Special,
heart-felt thanks to

- [**@fufexan**](https://github.com/fufexan) - For the transition to flake-parts
  and invaluable Nix assistance.
- [**@FlafyDev**](https://github.com/FlafyDev) - For getting Home-Manager module
  to work and Nix assistance.
- [**@n3oney**](https://github.com/n3oney) - For making custom keybinds finally
  possible, great ideas and module additions.
- [**@Yavko**](https://github.com/Yavko) - For the amazing **nvf** logo
- [**@FrothyMarrow**](https://github.com/FrothyMarrow) - For seeing mistakes
  that I could not and contributing good ideas & code.
- [**@Gerg-l**](https://github.com/gerg-l) 🐸 - For the modern Neovim wrapper,
  [mnw], and occasional improvements to the codebase.
- [**@Diniamo**](https://github.com/Diniamo) - For actively submitting pull
  requests, issues and assistance with co-maintenance of nvf.

and everyone who has submitted issues or pull requests!

### Inspiration

This configuration borrows from, and is based on a few other configurations,
including:

- [@jordanisaacs's](https://github.com/jordanisaacs)
  [**neovim-flake**](https://github.com/jordanisaacs/neovim-flake) that this
  flake is originally based on.
- [@wiltaylor's](https://github.com/wiltaylor)
  [neovim-flake](https://github.com/wiltaylor/neovim-flake) for plugin and
  design ideas.
- [@gvolpe's](https://github.com/gvolpe)
  [neovim-flake](https://github.com/gvolpe/neovim-flake) for plugin, design and
  nix concepts.
- [@sioodmy's](https://github.com/sioodmy)
  [dotfiles](https://github.com/sioodmy/dotfiles) that inspired the design
  choices for UI and plugin defaults.

I am grateful for their previous work and inspiration, and I wholeheartedly
recommend checking their work out.

## License

Following the license of
[the original neovim-flake](https://github.com/jordanisaacs/neovim-flake), nvf
has been made available under the [**MIT License**](LICENSE). However, all
assets and documentation are published under the
[**CC BY License**](https://github.com/NotAShelf/nvf/blob/main/.github/assets/LICENSE)
under explicit permission by the author or authors.

<h6 align="center">Yes, this includes the logo work too. Stop taking artwork that is not yours!</h6>

---

<div align="right">
  <a href="#readme">Back to the Top</a>
</div>
