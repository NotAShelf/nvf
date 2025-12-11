# Hacking nvf {#ch-hacking}

[open issues]: https://github.com/notashelf/nvf/issues
[new issue]: https://github.com/notashelf/nvf/issues/new

nvf is designed for the developer as much as it is designed for the end-user. We
would like for any contributor to be able to propagate their changes, or add new
features to the project with minimum possible friction. As such, below are the
guides and guidelines written to streamline the contribution process and to
ensure that your valuable input integrates into nvf's development as seamlessly
as possible without leaving any question marks in your head.

This section is directed mainly towards those who wish to contribute code into
the project. If you instead wish to report a bug, or discuss a potential new
feature implementation (which you do not wish to implement yourself) first look
among the already [open issues] and if no matching issue exists you may open a
[new issue] and describe your problem/request.

While creating an issue, please try to include as much information as you can,
ideally also include relevant context in which an issue occurs or a feature
should be implemented. If you wish to make a contribution, but feel stuck -
please do not be afraid to submit a pull request, we will help you get it in.

## Getting Started {#sec-contrib-getting-started}

You, naturally, would like to start by forking the repository to get started. If
you are new to Git and GitHub, do have a look at GitHub's
[Fork a repo guide](https://help.github.com/articles/fork-a-repo/) for
instructions on how you can do this. Once you have a fork of **nvf**, you should
create a separate branch based on the most recent `main` branch. Give your
branch a reasonably descriptive name (e.g. `feature/debugger` or
`fix/pesky-bug`) and you are ready to work on your changes

Implement your changes and commit them to the newly created branch and when you
are happy with the result, and positive that it fulfills our
[Contributing Guidelines](#sec-guidelines), push the branch to GitHub and
[create a pull request](https://help.github.com/articles/creating-a-pull-request).
The default pull request template available on the **nvf** repository will guide
you through the rest of the process, and we'll gently nudge you in the correct
direction if there are any mistakes.

## Guidelines {#sec-guidelines}

If your contribution tightly follows the guidelines, then there is a good chance
it will be merged without too much trouble. Some of the guidelines will be
strictly enforced, others will remain as gentle nudges towards the correct
direction. As we have no automated system enforcing those guidelines, please try
to double check your changes before making your pull request in order to avoid
"faulty" code slipping by.

If you are uncertain how these rules affect the change you would like to make
then feel free to start a discussion in the
[discussions tab](https://github.com/NotAShelf/nvf/discussions) ideally (but not
necessarily) before you start developing.

### Adding Documentation {#sec-guidelines-documentation}

[Nixpkgs Flavoured Markdown]: https://github.com/NixOS/nixpkgs/blob/master/doc/README.md#syntax

Almost all changes warrant updates to the documentation: at the very least, you
must update the changelog. Both the manual and module options use
[Nixpkgs Flavoured Markdown].

The HTML version of this manual containing both the module option descriptions
and the documentation of **nvf** (such as this page) can be generated and opened
by typing the following in a shell within a clone of the **nvf** Git repository:

```console
$ nix build .#docs-html
$ xdg-open $PWD/result/share/doc/nvf/index.html
```

### Formatting Code {#sec-guidelines-formatting}

Make sure your code is formatted as described in
[code-style section](#sec-guidelines-code-style). To maintain consistency
throughout the project you are encouraged to browse through existing code and
adopt its style also in new code.

### Formatting Commits {#sec-guidelines-commit-message-style}

Similar to [code style guidelines](#sec-guidelines-code-style) we encourage a
consistent commit message format as described in
[commit style guidelines](#sec-guidelines-commit-style).

### Commit Style {#sec-guidelines-commit-style}

The commits in your pull request should be reasonably self-contained. Which
means each and every commit in a pull request should make sense both on its own
and in general context. That is, a second commit should not resolve an issue
that is introduced in an earlier commit. In particular, you will be asked to
amend any commit that introduces syntax errors or similar problems even if they
are fixed in a later commit.

The commit messages should follow the
[seven rules](https://chris.beams.io/posts/git-commit/#seven-rule), except for
"Capitalize the subject line". We also ask you to include the affected code
component or module in the first line. A commit message ideally, but not
necessarily, follow the given template from home-manager's own documentation

```
  {component}: {description}

  {long description}
```

where `{component}` refers to the code component (or module) your change
affects, `{description}` is a very brief description of your change, and
`{long description}` is an optional clarifying description. As a rare exception,
if there is no clear component, or your change affects many components, then the
`{component}` part is optional. See
[example commit message](#sec-guidelines-ex-commit-message) for a commit message
that fulfills these requirements.

#### Example Commit {#sec-guidelines-ex-commit-message}

The commit
[69f8e47e9e74c8d3d060ca22e18246b7f7d988ef](https://github.com/nix-community/home-manager/commit/69f8e47e9e74c8d3d060ca22e18246b7f7d988ef)
in home-manager contains the following commit message.

```
starship: allow running in Emacs if vterm is used

The vterm buffer is backed by libvterm and can handle Starship prompts
without issues.
```

Similarly, if you are contributing to **nvf**, you would include the scope of
the commit followed by the description:

```
languages/ruby: init module

Adds a language module for Ruby, adds appropriate formatters and Treesitter grammars
```

Long description can be omitted if the change is too simple to warrant it. A
minor fix in spelling or a formatting change does not warrant long description,
however, a module addition or removal does as you would like to provide the
relevant context, i.e. the reasoning behind it, for your commit.

Finally, when adding a new module, say `modules/foo.nix`, we use the fixed
commit format `foo: add module`. You can, of course, still include a long
description if you wish.

In case of nested modules, i.e `modules/languages/java.nix` you are recommended
to contain the parent as well - for example `languages/java: some major change`.

### Code Style {#sec-guidelines-code-style}

#### Treewide {#sec-code-style-treewide}

Keep lines at a reasonable width, ideally 80 characters or less. This also
applies to string literals and module descriptions and documentation.

#### Nix {#sec-code-style-nix}

[alejandra]: https://github.com/kamadorueda/alejandra

**nvf** is formatted by the [alejandra] tool and the formatting is checked in
the pull request and push workflows. Run the `nix fmt` command inside the
project repository before submitting your pull request.

While Alejandra is mostly opinionated on how code looks after formatting,
certain changes are done at the user's discretion based on how the original code
was structured.

Please use one line code for attribute sets that contain only one subset. For
example:

```nix
# parent modules should always be unfolded
# which means module = { value = ... } instead of module.value = { ... }
module = {
  value = mkEnableOption "some description" // { default = true; }; # merges can be done inline where possible

    # same as parent modules, unfold submodules
    subModule = {
        # this is an option that contains more than one nested value
        # Note: try to be careful about the ordering of `mkOption` arguments.
        # General rule of thumb is to order from least to most likely to change.
        # This is, for most cases, type < default < description.
        # Example, if present, would be between default and description
        someOtherValue = mkOption {
            type = lib.types.bool;
            default = true;
            description = "Some other description";
        };
    };
}
```

If you move a line down after the merge operator, Alejandra will automatically
unfold the whole merged attrset for you, which we **do not** want.

```nix
module = {
  key = mkEnableOption "some description" // {
    default = true; # we want this to be inline
  }; # ...
}
```

For lists, it is mostly up to your own discretion how you want to format them,
but please try to unfold lists if they contain multiple items and especially if
they are to include comments.

```nix
# this is ok
acceptableList = [
  item1 # comment
  item2
  item3 # some other comment
  item4
];

# this is not ok
listToBeAvoided = [item1 item2 /* comment */ item3 item4];

# this is ok
acceptableList = [item1 item2];

# this is also ok if the list is expected to contain more elements
acceptableList= [
  item1
  item2
  # more items if needed...
];
```

## Testing Changes {#sec-testing-changes}

Once you have made your changes, you will need to test them thoroughly. If it is
a module, add your module option to `configuration.nix` (located in the root of
this project) inside `neovimConfiguration`. Enable it, and then run the maximal
configuration with `nix run .#maximal -Lv` to check for build errors. If neovim
opens in the current directory without any error messages (you can check the
output of `:messages` inside neovim to see if there are any errors), then your
changes are good to go. Open your pull request, and it will be reviewed as soon
as possible.

If it is not a new module, but a change to an existing one, then make sure the
module you have changed is enabled in the maximal configuration by editing
`configuration.nix`, and then run it with `nix run .#maximal -Lv`. Same
procedure as adding a new module will apply here.

## Keybinds {#sec-keybinds}

As of 0.4, there exists an API for writing your own keybinds and a couple of
useful utility functions are available in the
[extended standard library](https://github.com/NotAShelf/nvf/tree/main/lib). The
following section contains a general overview to how you may utilize said
functions.

## Custom Key Mappings Support for a Plugin {#sec-custom-key-mappings}

To set a mapping, you should define it in `vim.keymaps`.

An example, simple keybinding, can look like this:

```nix
{
  vim.keymaps = [
    {
      key = "<leader>wq";
      mode = ["n"];
      action = ":wq<CR>";
      silent = true;
      desc = "Save file and quit";
    }
  ];
}
```

There are many settings available in the options. Please refer to the
[documentation](./options.html#option-vim-keymaps) to see a list of them.

**nvf** provides a helper function, so that you don't have to write the mapping
attribute sets every time:

- `mkKeymap`, which mimics neovim's `vim.keymap.set` function

You can read the source code of some modules to see them in action, but the
usage should look something like this:

```nix
# plugindefinition.nix
{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.binds) mkMappingOption;
in {
  options.vim.plugin = {
    enable = mkEnableOption "Enable plugin";

    # Mappings should always be inside an attrset called mappings
    mappings = {
      workspaceDiagnostics = mkMappingOption "Workspace diagnostics [trouble]" "<leader>lwd";
      documentDiagnostics = mkMappingOption "Document diagnostics [trouble]" "<leader>ld";
      lspReferences = mkMappingOption "LSP References [trouble]" "<leader>lr";
      quickfix = mkMappingOption "QuickFix [trouble]" "<leader>xq";
      locList = mkMappingOption "LOCList [trouble]" "<leader>xl";
      symbols = mkMappingOption "Symbols [trouble]" "<leader>xs";
    };
}
```

```nix
# config.nix
{
  config,
  lib,
  options,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.binds) mkKeymap;

  cfg = config.vim.plugin;

  keys = cfg.mappings;
  inherit (options.vim.lsp.trouble) mappings;
in {
  config = mkIf cfg.enable {
    vim.keymaps = [
      (mkKeymap "n" keys.workspaceDiagnostics "<cmd>Trouble toggle diagnostics<CR>" {desc = mappings.workspaceDiagnostics.description;})
      (mkKeymap "n" keys.documentDiagnostics "<cmd>Trouble toggle diagnostics filter.buf=0<CR>" {desc = mappings.documentDiagnostics.description;})
      (mkKeymap "n" keys.lspReferences "<cmd>Trouble toggle lsp_references<CR>" {desc = mappings.lspReferences.description;})
      (mkKeymap "n" keys.quickfix "<cmd>Trouble toggle quickfix<CR>" {desc = mappings.quickfix.description;})
      (mkKeymap "n" keys.locList "<cmd>Trouble toggle loclist<CR>" {desc = mappings.locList.description;})
      (mkKeymap "n" keys.symbols "<cmd>Trouble toggle symbols<CR>" {desc = mappings.symbols.description;})
    ];
  };
}
```

> [!NOTE]
> If you have come across a plugin that has an API that doesn't seem to easily
> allow custom keybindings, don't be scared to implement a draft PR. We'll help
> you get it done.

## Adding Plugins {#sec-additional-plugins}

There are two methods for adding new Neovim plugins to **nvf**. npins is the
faster option that should be preferred if the plugin consists of pure Lua or
Vimscript code. In which case there is no building required, and we can easily
handle the copying of plugin files. Alternative method, which is required when
plugins try to build their own libraries (e.g., in Rust or C) that need to be
built with Nix to function correctly.

### With npins {#sec-npins-for-plugins}

npins is the standard method of adding new plugins to **nvf**. You simply need
the repository URL for the plugin, and can add it as a source to be built
automatically with one command. To add a new Neovim plugin, use `npins`. For
example:

```bash
nix-shell -p npins # or nix shell nixpkgs#npins if using flakes
```

Then run:

```bash
npins add --name <plugin name> github <owner> <repo> -b <branch>
```

::: {.note}

Be sure to replace any non-alphanumeric characters with `-` for `--name`. For
example

```bash
npins add --name lazydev-nvim github folke lazydev.nvim -b main
```

:::

Once the `npins` command is done, you can start referencing the plugin as a
**string**.

```nix
{
  config.vim.startPlugins = ["lazydev-nvim"];
}
```

### Packaging Complex Plugins {#sec-pkgs-for-plugins}

[blink.cmp]: https://github.com/Saghen/blink.cmp

Some plugins require additional packages to be built and substituted to function
correctly. For example [blink.cmp] requires its own fuzzy matcher library, built
with Rust, to be installed or else defaults to a much slower Lua implementation.
In the Blink documentation, you are advised to build with `cargo` but that is
not ideal since we are leveraging the power of Nix. In this case the ideal
solution is to write a derivation for the plugin.

We use `buildRustPackage` to build the library from the repository root, and
copy everything in the `postInstall` phase.

```nix
postInstall = ''
  cp -r {lua,plugin} "$out"

  mkdir -p "$out/doc"
  cp 'doc/'*'.txt' "$out/doc/"

  mkdir -p "$out/target"
  mv "$out/lib" "$out/target/release"
'';
```

In a similar fashion, you may utilize `stdenv.mkDerivation` and other Nixpkgs
builders to build your library from source, and copy the relevant files and Lua
plugin files in the `postInstall` phase. Do note, however, that you still need
to fetch the plugin sources somehow. npins is, once again, the recommended
option to fetch the plugin sources. Refer to the previous section on how to use
npins to add a new plugin.

Plugins built from source must go into the `flake/pkgs/by-name` overlay. It will
automatically create flake outputs for individual packages. Lastly, you must add
your package to the plugin builder (`pluginBuilders`) function manually in
`modules/wrapper/build/config.nix`. Once done, you may refer to your plugin as a
**string**.

```nix
{
  config.vim.startPlugins = ["blink-cmp"];
}
```

### Modular setup options {#sec-modular-setup-options}

Most plugins is initialized with a call to `require('plugin').setup({...})`.

We use a special function that lets you easily add support for such setup
options in a modular way: `mkPluginSetupOption`.

Once you have added the source of the plugin as shown above, you can define the
setup options like this:

```nix
# in modules/.../your-plugin/your-plugin.nix

{lib, ...}:
let
  inherit (lib.types) bool int;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.your-plugin = {
    setupOpts = mkPluginSetupOption "plugin name" {
      enable_feature_a = mkOption {
        type = bool;
        default = false;
        # ...
      };

      number_option = mkOption {
        type = int;
        default = 3;
        # ...
      };
    };
  };
}
```

```nix
# in modules/.../your-plugin/config.nix
{lib, config, ...}:
let
  cfg = config.vim.your-plugin;
in {
  vim.luaConfigRC = lib.nvim.dag.entryAnywhere ''
    require('plugin-name').setup(${lib.nvim.lua.toLuaObject cfg.setupOpts})
  '';
}
```

This above config will result in this Lua script:

```lua
require('plugin-name').setup({
  enable_feature_a = false,
  number_option = 3,
})
```

Now users can set any of the pre-defined option field, and can also add their
own fields!

```nix
# in user's config
{
  vim.your-plugin.setupOpts = {
    enable_feature_a = true;
    number_option = 4;
    another_field = "hello";
    size = { # nested fields work as well
      top = 10;
    };
  };
}
```

### Details of toLuaObject {#sec-details-of-toluaobject}

As you've seen above, `toLuaObject` is used to convert our nix attrSet
`cfg.setupOpts`, into a lua table. Here are some rules of the conversion:

1. Nix `null` converts to lua `nil`
2. Number and strings convert to their lua counterparts
3. Nix attribute sets (`{}`) and lists (`[]`) convert into Lua dictionaries and
   tables respectively. Here is an example of Nix -> Lua conversion.
   - `{foo = "bar"}` -> `{["foo"] = "bar"}`
   - `["foo" "bar"]` -> `{"foo", "bar"}`
4. You can write raw Lua code using `lib.generators.mkLuaInline`. This function
   is part of nixpkgs, and is accessible without relying on **nvf**'s extended
   library.
   - `mkLuaInline "function add(a, b) return a + b end"` will yield the
     following result:

   ```nix
   {
    _type = "lua-inline";
    expr = "function add(a, b) return a + b end";
   }
   ```

   The above expression will be interpreted as a Lua expression in the final
   config. Without the `mkLuaInline` function, you will only receive a string
   literal. You can use it to feed plugin configuration tables Lua functions
   that return specific values as expected by the plugins.

   ```nix
   {
      vim.your-plugin.setupOpts = {
        on_init = lib.generators.mkLuaInline ''
          function()
            print('we can write lua!')
          end
        '';
      };
   }
   ```

### Lazy plugins {#sec-lazy-plugins}

If the plugin can be lazy-loaded, `vim.lazy.plugins` should be used to add it.
Lazy plugins are managed by `lz.n`.

```nix
# in modules/.../your-plugin/config.nix
{config, ...}: let
  cfg = config.vim.your-plugin;
in {
  vim.lazy.plugins.your-plugin = {
    # Instead of vim.startPlugins, use this:
    package = "your-plugin";

    # ıf your plugin uses the `require('your-plugin').setup{...}` pattern
    setupModule = "your-plugin";
    inherit (cfg) setupOpts;

    # Events that trigger this plugin to be loaded
    event = ["DirChanged"];
    cmd = ["YourPluginCommand"];

    # Plugin Keymaps
    keys = [
      # We'll cover this in detail in the 'keybinds' section
      {
        key = "<leader>d";
        mode = "n";
        action = ":YourPluginCommand";
      }
    ];
  };
}
```

This results in the following lua code:

```lua
require('lz.n').load({
  {
    "name-of-your-plugin",
    after = function()
      require('your-plugin').setup({
        --[[ your setupOpts ]]--
      })
    end,

    event = {"DirChanged"},
    cmd = {"YourPluginCommand"},
    keys = {
      {"<leader>d", ":YourPluginCommand", mode = {"n"}},
    },
  }
})
```

[`vim.lazy.plugins` spec]: ./options.html#option-vim-lazy-plugins

A full list of options can be found in the [`vim.lazy.plugins` spec] on the
rendered manual.
