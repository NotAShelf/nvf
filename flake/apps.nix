{lib, ...}: {
  perSystem = {
    system,
    config,
    ...
  }: {
    apps =
      {
        nix.program = lib.getExe config.packages.nix;
        maximal.program = lib.getExe config.packages.maximal;
        default = config.apps.nix;
      }
      // (
        if !(builtins.elem system ["aarch64-darwin" "x86_64-darwin"])
        then {
          tidal.program = lib.getExe config.packages.tidal;
        }
        else {}
      );
  };
}
