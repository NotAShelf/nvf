# TODO: I need testing.
{
  pkgs,
  lib,
  ...
} @ moduleInheritancePackage: let
  # The name of the builder
  name = "latexmk";

  # The builder template
  template = import ./builderTemplate.nix;

  inherit (lib) optionals;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) bool package str;
in (
  template {
    inherit name moduleInheritancePackage;

    options = {
      enable = mkEnableOption "Whether to enable Tex Compilation Via latexmk";

      package = mkOption {
        type = package;
        default = pkgs.texlive.withPackages (ps: [ps.latexmk]);
        description = "latexmk package";
      };

      executable = mkOption {
        type = str;
        default = "latexmk";
        description = "The executable name from the build package that will be used to build/compile the tex.";
      };

      # Flag options
      pdfOutput = mkOption {
        type = bool;
        default = true;
        example = false;
        description = "Insure the output file is a pdf.";
      };
    };

    args = builderCfg: (
      # Flags
      (optionals builderCfg.pdfOutput ["-pdf"])
      # Base args
      ++ [
        "-quiet"
        "%f"
      ]
    );
  }
)
