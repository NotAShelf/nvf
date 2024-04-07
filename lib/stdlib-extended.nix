# Cconvenience function that returns the given Nixpkgs standard library
# extended with our functions using `lib.extend`.
nixpkgsLib: let
  mkNvimLib = import ./.;
in
  # WARNING: New functions should not be added here, but to files
  # imported by `./default.nix` under their own categories. If your
  # function does not fit to any of the existing categories, create
  # a new file and import it in `./default.nix.`
  nixpkgsLib.extend (self: super: {
    nvim = mkNvimLib {lib = self;};

    # For forward compatibility.
    literalExpression = super.literalExpression or super.literalExample;
  })
