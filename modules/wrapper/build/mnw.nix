{
  inputs,
  lib,
  pkgs,
  config,
  ...
}: {
  options.mnw = lib.mkOption {
    type = lib.types.submoduleWith {
      specialArgs = {
        inherit pkgs;
        modulesPath = toString (inputs.mnw + /modules);
      };
      modules = [
        (inputs.mnw + /modules/options.nix)
      ];
    };
    default = {};
    description = ''
      Internal options passed directly to mnw itself.
    '';
  };
  config = {
    warnings = map (warning: "mnw: ${warning}") config.mnw.warnings;
    assertions =
      map (assertion: {
        inherit (assertion) assertion;
        message = "mnw: ${assertion.message}";
      })
      config.mnw.assertions;

    mnw.finalPackage = inputs.mnw.lib.uncheckedWrap pkgs config.mnw;
  };
}
