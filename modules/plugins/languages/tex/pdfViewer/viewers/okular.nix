{
  pkgs,
  lib,
  ...
} @ moduleInheritencePackage: let
  # The name of the pdf viewer
  name = "okular";

  # The viewer template
  template = import ./viewerTemplate.nix;

  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) package str listOf;
in (
  template {
    inherit name moduleInheritencePackage;

    options = {
      enable = mkEnableOption "enable okular as the pdf file previewer.";

      package = mkOption {
        type = package;
        default = pkgs.okular;
        description = "okular package";
      };

      executable = mkOption {
        type = str;
        default = "okular";
        description = "The executable name to call the viewer.";
      };

      args = mkOption {
        type = listOf str;
        default = ["--unique" "file:%p#src:%l%f"];
        description = "Arguments to pass to the viewer.";
      };
    };

    argsFunction = viewerCfg: (viewerCfg.args);
  }
)
