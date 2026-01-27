<!--
^ Please include a clear and concise description of the aim of your Pull Request above this line ^

For plugin dependency/module additions, please make sure to link the source link of the added plugin
or dependency in this section.

If your pull request aims to fix an open issue or a please bug, please also link the relevant issue
below this line. You may attach an issue to your pull request with `Fixes #<issue number>` outside
this comment, and it will be closed when your pull request is merged.

A developer package template is provided in flake/develop.nix. If working on a module, you may use
it to test your changes with minimal dependency changes.
-->

## Sanity Checking

<!--
Please check all that apply. As before, this section is not a hard requirement but checklists with more checked
items are likely to be merged faster. You may save some time in maintainer reviews by performing self-reviews
here before submitting your pull request.

If your pull request includes any change or unexpected behaviour not covered below, please do make sure to include
it above in your description.
-->

[editorconfig]: https://editorconfig.org
[changelog]: https://github.com/NotAShelf/nvf/tree/main/docs/manual/release-notes
[hacking nvf]: https://nvf.notashelf.dev/hacking.html#sec-guidelines

- [ ] I have updated the [changelog] as per my changes
- [ ] I have tested, and self-reviewed my code
- [ ] My changes fit guidelines found in [hacking nvf]
- Style and consistency
  - [ ] I ran **Alejandra** to format my code (`nix fmt`)
  - [ ] My code conforms to the [editorconfig] configuration of the project
  - [ ] My changes are consistent with the rest of the codebase
- If new changes are particularly complex:
  - [ ] My code includes comments in particularly complex areas
  - [ ] I have added a section in the manual
  - [ ] _(For breaking changes)_ I have included a migration guide
- Package(s) built:
  - [ ] `.#nix` _(default package)_
  - [ ] `.#maximal`
  - [ ] `.#docs-html` _(manual, must build)_
  - [ ] `.#docs-linkcheck` _(optional, please build if adding links)_
- Tested on platform(s)
  - [ ] `x86_64-linux`
  - [ ] `aarch64-linux`
  - [ ] `x86_64-darwin`
  - [ ] `aarch64-darwin`

<!--
If your changes touch upon a portion of the codebase that you do not understand well, please make sure to consult
the maintainers on your changes. In most cases, making an issue before creating your PR will help you avoid duplicate
efforts in the long run. `git blame` might help you find out who is the "author" or the "maintainer" of a current
module by showing who worked on it the most.
-->

---

Add a :+1: [reaction] to [pull requests you find important].

[reaction]: https://github.blog/2016-03-10-add-reactions-to-pull-requests-issues-and-comments/
[pull requests you find important]: https://github.com/NixOS/nixpkgs/pulls?q=is%3Aopen+sort%3Areactions-%2B1-desc
