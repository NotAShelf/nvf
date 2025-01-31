{
  pkgs,
  lib,
  ...
} @ moduleInheritencePackage: let
  # The name of the pdf viewer
  name = "custom";

  # The viewer template
  template = import ./viewerTemplate.nix;

  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) package str listOf;
in (
  template {
    inherit name moduleInheritencePackage;

    options = {
      enable = mkEnableOption "enable using a custom pdf viewer.";

      package = mkOption {
        type = package;
        example = pkgs.okular;
        description = "custom viewer package";
      };

      executable = mkOption {
        type = str;
        example = "okular";
        description = "The executable name to call the viewer.";
      };

      args = mkOption {
        type = listOf str;
        example = ["--unique" "file:%p#src:%l%f"];
        description = "Arguments to pass to the viewer.";
      };
    };

    argsFunction = viewerCfg: (viewerCfg.args);
  }
)
