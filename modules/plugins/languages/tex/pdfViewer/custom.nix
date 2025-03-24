{
  pkgs,
  lib,
  ...
} @ moduleInheritancePackage: let
  # The name of the pdf viewer
  name = "custom";

  # The viewer template
  template = import ./viewerTemplate.nix;

  inherit (lib.options) mkOption mkEnableOption mkPackageOption;
  inherit (lib.types) str listOf;
in (
  template {
    inherit name moduleInheritancePackage;

    options = {
      enable = mkEnableOption "enable using a custom pdf viewer.";

      package = mkPackageOption pkgs "okular" {
        extraDescription = "custom viewer package";
      };

      executable = mkOption {
        type = str;
        example = "okular";
        description = "The executable name to call the viewer.";
      };

      args = mkOption {
        type = listOf str;
        example = [
          "--unique"
          "file:%p#src:%l%f"
        ];
        description = "Arguments to pass to the viewer.";
      };
    };

    argsFunction = viewerCfg: (viewerCfg.args);
  }
)
