{lib, ...}: {
  perSystem = {
    pkgs,
    config,
    self',
    ...
  }: {
    devShells = {
      default = self'.devShells.lsp;
      nvim-nix = pkgs.mkShellNoCC {packages = [config.packages.nix];};
      lsp = pkgs.mkShellNoCC {
        packages = with pkgs; [nil statix deadnix alejandra npins];
      };
    };

    # This package exists to make development easier by providing the place and
    # boilerplate to build a test nvf configuration. Feel free to use this for
    # testing, but make sure to discard the changes before creating a pull
    # request.
    packages.dev = let
      configuration = {};

      customNeovim = lib.nvim.neovimConfiguration {
        inherit pkgs;
        modules = [configuration];
      };
    in
      customNeovim.neovim;
  };
}
