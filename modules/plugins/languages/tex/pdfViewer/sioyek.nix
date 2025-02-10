{
  pkgs,
  lib,
  ...
} @ moduleInheritancePackage: let
  # The name of the pdf viewer
  name = "sioyek";

  # The viewer template
  template = import ./viewerTemplate.nix;

  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) package str listOf;
in (
  template {
    inherit name moduleInheritancePackage;

    options = {
      enable = mkEnableOption "enable sioyek as the pdf file previewer.";

      package = mkOption {
        type = package;
        default = pkgs.sioyek;
        description = "sioyek package";
      };

      executable = mkOption {
        type = str;
        default = "sioyek";
        description = "The executable name to call the viewer.";
      };

      args = mkOption {
        type = listOf str;
        default = [
          "--reuse-window"
          "--execute-command"
          "toggle_synctex"
          "--inverse-search"
          "texlab inverse-search -i \"%%1\" -l %%2"
          "--forward-search-file"
          "%f"
          "--forward-search-line"
          "%l"
          "%p"
        ];
        description = ''
          Arguments to pass to the viewer.

          By default, this is the only viewer that supports the inverse search feature by
          command line arguments and doesn't explicitly require extra tinkering else where
          in your config.
        '';
      };
    };

    argsFunction = viewerCfg: (viewerCfg.args);
  }
)
