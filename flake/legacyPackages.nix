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
          # Build nil from source to get most recent
          # features as they are added.
          nil = inputs'.nil.packages.default;
        })
      ];
    };
  };
}
