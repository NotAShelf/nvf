# TODO: I need testing.
{
  config,
  lib,
  pkgs,
  ...
}: let
  # The name of the builder
  name = "latexmk";

  inherit (lib.modules) mkIf;
  inherit (lib.nvim.config) mkBool;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) package str;

  texCfg = config.vim.languages.tex;
  cfg = texCfg.build.builders.${name};
in {
  options.vim.languages.tex.build.builders.${name} = {
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
    pdfOutput = mkBool true "Insure the output file is a pdf.";
  };

  config = mkIf (texCfg.enable && cfg.enable) {
    vim.languages.tex.build.builder = {
      inherit name;
      inherit (cfg) package executable;
      args = (
        # Flags
        (lib.lists.optional cfg.pdfOutput "-pdf")
        # Base args
        ++ [
          "-quiet"
          "%f"
        ]
      );
    };
  };
}
