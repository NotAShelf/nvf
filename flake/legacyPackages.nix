{
  inputs,
  self,
  ...
}: {
  perSystem = {
    system,
    inputs',
    ...
  }: {
    legacyPackages = import inputs.nixpkgs {
      inherit system;
      overlays = [
        inputs.self.overlays.default

        (final: prev: {
          # Build nil from source to get most recent
          # features as they are added.
          nil = inputs'.nil.packages.default;
          blink-cmp = let
            pin = self.pins.blink-cmp;
          in
            final.callPackage ./legacyPackages/blink-cmp.nix {
              inherit (pin) version;
              src = prev.fetchFromGitHub {
                inherit (pin.repository) owner repo;
                rev = pin.revision;
                sha256 = pin.hash;
              };
            };
        })
      ];
    };
  };
}
