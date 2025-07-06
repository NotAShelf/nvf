# Convenience function that returns the given Nixpkgs standard library
# extended with our functions using `lib.extend`.
{inputs, ...} @ args:
inputs.nixpkgs.lib.extend (self: super: {
  # WARNING: New functions should not be added here, but to files
  # imported by `./default.nix` under their own categories. If your
  # function does not fit to any of the existing categories, create
  # a new file and import it in `./default.nix.`

  # Makes our custom functions available under `lib.nvim` where stdlib-extended.nix is imported
  # with the appropriate arguments. For end-users, a `lib` output will be accessible from the flake.
  # E.g. for an input called `nvf`, `inputs.nvf.lib.nvim` will return the set
  # below.
  nvim = import ./. {
    inherit (args) inputs self;
    lib = self;
  };

  # For forward compatibility.
  literalExpression = super.literalExpression or super.literalExample;
})
