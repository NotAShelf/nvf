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

        (final: _: {
          # Build nil from source to get most recent
          # features as they are added.
          nil = inputs'.nil.packages.default;
          blink-cmp = final.callPackage ./legacyPackages/blink-cmp.nix {
            src = inputs.plugin-blink-cmp;
            version = inputs.plugin-blink-cmp.shortRev or inputs.plugin-blink-cmp.shortDirtyRev or "dirty";
          };
        })
      ];
    };
  };
}
