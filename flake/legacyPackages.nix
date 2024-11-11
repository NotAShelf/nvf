{inputs, ...}: {
  perSystem = {
    system,
    inputs',
    ...
  }: {
    legacyPackages = import inputs.nixpkgs {
      inherit system;
      overlays = [
        inputs.self.overlays.default
        (_: _: {
          rnix-lsp = inputs'.rnix-lsp.defaultPackage;
          nil = inputs'.nil.packages.default;
          nixd = inputs'.nixd.packages.default;
        })
      ];
    };
  };
}
