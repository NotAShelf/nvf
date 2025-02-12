{
  pkgs,
  lib,
  ...
} @ moduleInheritancePackage: let
  # The name of the pdf viewer
  name = "zathura";

  # The viewer template
  template = import ./viewerTemplate.nix;

  inherit (lib.options) mkOption mkEnableOption mkPackageOption;
  inherit (lib.types) str listOf;
in (
  template {
    inherit name moduleInheritancePackage;

    options = {
      enable = mkEnableOption "enable zathura as the pdf file previewer.";

      package = mkPackageOption pkgs "zathura" {};

      executable = mkOption {
        type = str;
        default = "zathura";
        description = "The executable name to call the viewer.";
      };

      args = mkOption {
        type = listOf str;
        default = [
          "--synctex-forward"
          "%l:1:%f"
          "%p"
        ];
        description = "Arguments to pass to the viewer.";
      };
    };

    argsFunction = viewerCfg: (viewerCfg.args);
  }
)
