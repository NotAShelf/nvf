{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nvf.url = "github:notashelf/nvf";
  };

  outputs = {nixpkgs, ...} @ inputs: let
    # An abstraction over systems to easily provide the same package
    # for multiple systems. This is preferable to abstraction libraries.
    forEachSystem = nixpkgs.lib.genAttrs [
      "x86_64-linux"
      "aarch64-linux"
    ];
  in {
    packages = forEachSystem (system: let
      pkgs = inputs.nixpkgs.legacyPackages.${system};
    in {
      # Packages to be exposed under packages.<system>. Those can accessed
      # directly from package outputs in other flakes if this flake is added
      # as an input. You may run those packages with 'nix run .#<package>'
      default =
        (inputs.nvf.lib.neovimConfiguration {
          inherit pkgs;

          modules = [
            # Configuration module to be imported. You may define multiple modules
            # or even import them from other files (e.g., ./modules/lsp.nix) to
            # better modularize your configuration.
            ./configuration.nix
          ];
        }).neovim;
    });
  };
}
