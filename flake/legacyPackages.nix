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
            src = inputs.blink-cmp;
            version = inputs.blink-cmp.shortRev or inputs.blink-cmp.shortDirtyRev or "dirty";
          };
        })
      ];
    };
  };
}
