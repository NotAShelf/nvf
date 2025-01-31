{
  pkgs,
  lib,
  ...
} @ moduleInheritencePackage: let
  # The name of the pdf viewer
  name = "qpdfview";

  # The viewer template
  template = import ./viewerTemplate.nix;

  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) package str listOf;
in (
  template {
    inherit name moduleInheritencePackage;

    options = {
      enable = mkEnableOption "enable qpdfview as the pdf file previewer.";

      package = mkOption {
        type = package;
        default = pkgs.qpdfview;
        description = "qpdfview package";
      };

      executable = mkOption {
        type = str;
        default = "qpdfview";
        description = "The executable name to call the viewer.";
      };

      args = mkOption {
        type = listOf str;
        default = ["--unique" "%p#src:%f:%l:1"];
        description = "Arguments to pass to the viewer.";
      };
    };

    argsFunction = viewerCfg: (viewerCfg.args);
  }
)
