{inputs, ...}: {
  perSystem = {
    system,
    inputs',
    ...
  }: {
    legacyPackages = import inputs.nixpkgs {
      inherit system;
      overlays = [
        inputs.tidalcycles.overlays.default
        inputs.self.overlays.default
        inputs.zig.overlays.default
        (_: _: {
          rnix-lsp = inputs'.rnix-lsp.defaultPackage;
          nil = inputs'.nil.packages.default;
          zig = inputs'.zig.packages.default;
        })
      ];
    };
  };
}
