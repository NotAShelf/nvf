{lib, ...}: {
  perSystem = {pkgs, ...}: {
    # The default dev shell provides packages required to interact with
    # the codebase as described by the contributing guidelines. It includes the
    # formatters required, and a few additional goodies for linting work.
    devShells = {
      default = pkgs.mkShellNoCC {
        packages = with pkgs; [
          # Nix tooling
          nil # LSP
          statix # static checker
          deadnix # dead code finder

          # So that we can interact with plugin sources
          npins

          # Formatters
          alejandra
          deno
        ];
      };
    };

    # This package exists to make development easier by providing the place and
    # boilerplate to build a test nvf configuration. Feel free to use this for
    # testing, but make sure to discard the changes before creating a pull
    # request.
    packages.dev = let
      configuration = {
        # This is essentially the configuration that will be passed to the
        # builder function. For example:
        # vim.languages.nix.enable = true;
      };

      customNeovim = lib.nvim.neovimConfiguration {
        inherit pkgs;
        modules = [configuration];
      };
    in
      customNeovim.neovim;
  };
}
