# TODO: I need testing.
{
  config,
  pkgs,
  lib,
  ...
} @ moduleInheritencePackage: let
  # The name of the builder
  name = "latexmk";

  # The builder template
  template = import ./builderTemplate.nix;

  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) bool package str;

  cfg = config.vim.languages.tex;

  # --- Enable Options ---
  mkEnableDefaultOption = default: description: (mkOption {
    type = bool;
    default = default;
    example = !default;
    description = description;
  });
in (
  template {
    inherit name moduleInheritencePackage;

    options = {
      enable = mkEnableOption "Whether to enable Tex Compilation Via latexmk";

      package = mkOption {
        type = package;
        default = (pkgs.texlive.withPackages (ps: [ ps.latexmk ]));
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
      (
        if builderCfg.pdfOutput
        then ["-pdf"]
        else []
      )
      # Base args
      ++ [
        "-quiet"
        "%f"
      ]
    );
  }
)
