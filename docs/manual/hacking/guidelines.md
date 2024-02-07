# Guidelines {#sec-guidelines}

If your contribution tightly follows the guidelines, then there is a good chance it will be merged without too much
trouble. Some of the guidelines will be strictly enforced, others will remain as gentle nudges towards the correct
direction. As we have no automated system enforcing those guidelines, please try to double check your changes before
making your pull request in order to avoid "faulty" code slipping by.

If you are uncertain how these rules affect the change you would like to make then feel free to start a
discussion in the [discussions tab](https://github.com/NotAShelf/neovim-flake/discussions) ideally (but not necessarily)
before you start developing.

## Adding Documentation {#sec-guidelines-documentation}

Most, if not all, changes warrant changes to the documentation. Module options should be documented with
[Nixpkgs-flavoured Markdown](https://nixos.org/manual/nixpkgs/unstable/#sec-contributing-markup), albeit with exceptions.

:::{.note}

As of v0.5, neovim-flake is itself documented using full markdown in both module options and the manual. With
v0.6, this manual has also been converted to markdown in full.

:::

The HTML version of this manual containing both the module option descriptions and the documentation of neovim-flake
(such as this page) can be generated and opened by typing the following in a shell within a clone of the
neovim-flake Git repository:

```console
$ nix build .#docs-html
$ xdg-open $PWD/result/share/doc/neovim-flake/index.html
```

## Formatting Code {#sec-guidelines-formatting}

Make sure your code is formatted as described in [code-style section](#sec-guidelines-code-style). To maintain consistency throughout
the project you are encouraged to browse through existing code and adopt its style also in new code.

## Formatting Commits {#sec-guidelines-commit-message-style}

Similar to [code style guidelines](#sec-guidelines-code-style) we encourage a consistent commit message format as described
in [commit style guidelines](#sec-guidelines-commit-style).

## Commit Style {#sec-guidelines-commit-style}

The commits in your pull request should be reasonably self-contained. Which means each and every commit in
a pull request should make sense both on its own and in general context. That is, a second commit should not resolve
an issue that is introduced in an earlier commit. In particular, you will be asked to amend any commit that
introduces syntax errors or similar problems even if they are fixed in a later commit.

The commit messages should follow the [seven rules](https://chris.beams.io/posts/git-commit/#seven-rule),
except for "Capitalize the subject line". We also ask you to include the affected code component or module in
the first line. A commit message ideally, but not necessarily, follow the given template from home-manager's own documentation

```
  {component}: {description}

  {long description}
```

where `{component}` refers to the code component (or module) your change affects, `{description}` is a very brief
description of your change, and `{long description}` is an optional clarifying description. As a rare exception, if
there is no clear component, or your change affects many components, then the `{component}` part is optional.
See [example commit message](#sec-guidelines-ex-commit-message) for a commit message that fulfills these requirements.

## Example Commit {#sec-guidelines-ex-commit-message}

The commit [69f8e47e9e74c8d3d060ca22e18246b7f7d988ef](https://github.com/nix-community/home-manager/commit/69f8e47e9e74c8d3d060ca22e18246b7f7d988ef) contains the commit message

```

starship: allow running in Emacs if vterm is used

The vterm buffer is backed by libvterm and can handle Starship prompts
without issues.

```

Long description can be ommitted if the change is too simple to warrant it. A minor fix in spelling or a formatting
change does not warrant long description, however, a module addition or removal does as you would like to provide the
relevant context for your changes.

Finally, when adding a new module, say `modules/foo.nix`, we use the fixed commit format `foo: add module`.
You can, of course, still include a long description if you wish.

In case of nested modules, i.e `modules/languages/java.nix` you are recommended to contain the parent as well - for
example `languages/java: some major change`.

## Code Style {#sec-guidelines-code-style}

**Treewide**
Keep lines at a reasonable width, ideally 80 characters or less. This also applies to string literals and module
descriptions and documentation.

**Nix**
neovim-flake is formatted by the [alejandra](https://github.com/kamadorueda/alejandra) tool and the formatting is checked in the pull
request and push workflows. Run the `nix fmt` command inside the project repository before submitting your
pull request.

While Alejandra is mostly opinionated on how code looks after formatting, certain changes are done at the
user's discretion based on how the original code was structured.

Please use one line code for attribute sets that contain only one subset.
For example:

```nix
# parent modules should always be unfolded
# which means module = { value = ... } instead of module.value = { ... }
module = {
  value = mkEnableOption "some description" // { default = true; }; # merges can be done inline where possible

    # same as parent modules, unfold submodules
    subModule = {
        # this is an option that contains more than one nested value
        someOtherValue = mkOption {
            type = lib.types.bool;
            description = "Some other description";
            default = true;
        };
    };
}
```

If you move a line down after the merge operator, Alejandra will automatically unfold the whole merged attrset
for you, which we **do not** want.

```nix
module = {
  key = mkEnableOption "some description" // {
    default = true; # we want this to be inline
  }; # ...
}
```

For lists, it is mostly up to your own discretion how you want to format them, but please try to unfold lists if
they contain multiple items and especially if they are to include comments.

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
acceptableList = [item1];

# this is not ok
listToBeAvoided = [
  item1
];
```
