{
  pkgs,
  lib,
  ...
} @ moduleInheritencePackage: let
  # The name of the pdf viewer
  name = "zathura";

  # The viewer template
  template = import ./viewerTemplate.nix;

  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) package str listOf;
in (
  template {
    inherit name moduleInheritencePackage;

    options = {
      enable = mkEnableOption "enable zathura as the pdf file previewer.";

      package = mkOption {
        type = package;
        default = pkgs.zathura;
        description = "zathura package";
      };

      executable = mkOption {
        type = str;
        default = "zathura";
        description = "The executable name to call the viewer.";
      };

      args = mkOption {
        type = listOf str;
        default = ["--synctex-forward" "%l:1:%f" "%p"];
        description = "Arguments to pass to the viewer.";
      };
    };

    argsFunction = viewerCfg: (viewerCfg.args);
  }
)
