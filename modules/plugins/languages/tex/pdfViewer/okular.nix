{
  pkgs,
  lib,
  ...
} @ moduleInheritancePackage: let
  # The name of the pdf viewer
  name = "okular";

  # The viewer template
  template = import ./viewerTemplate.nix;

  inherit (lib.options) mkOption mkEnableOption mkPackageOption;
  inherit (lib.types) str listOf;
in (
  template {
    inherit name moduleInheritancePackage;

    options = {
      enable = mkEnableOption "enable okular as the pdf file previewer.";

      package = mkPackageOption pkgs "okular" {};

      executable = mkOption {
        type = str;
        default = "okular";
        description = "The executable name to call the viewer.";
      };

      args = mkOption {
        type = listOf str;
        default = [
          "--unique"
          "file:%p#src:%l%f"
        ];
        description = "Arguments to pass to the viewer.";
      };
    };

    argsFunction = viewerCfg: (viewerCfg.args);
  }
)
