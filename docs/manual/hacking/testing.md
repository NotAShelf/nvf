# Testing Changes {#sec-testing-changes}

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
