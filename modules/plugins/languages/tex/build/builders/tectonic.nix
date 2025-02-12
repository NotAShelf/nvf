{
  config,
  pkgs,
  lib,
  ...
} @ moduleInheritancePackage: let
  # The name of the builder
  name = "tectonic";

  # The builder template
  template = import ./builderTemplate.nix;

  inherit (lib) optionals;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) enum ints listOf package str;
  inherit (lib.nvim.config) mkBool;
  inherit (builtins) concatLists elem map toString;

  cfg = config.vim.languages.tex;
in (
  template {
    inherit name moduleInheritancePackage;

    options = {
      enable = mkEnableOption "Whether to enable Tex Compilation Via Tectonic";

      package = mkOption {
        type = package;
        default = pkgs.tectonic;
        description = "tectonic package";
      };

      executable = mkOption {
        type = str;
        default = "tectonic";
        description = "The executable name from the build package that will be used to build/compile the tex.";
      };

      # -- Flags --
      keepIntermediates = mkBool false ''
        Keep the intermediate files generated during processing.

        If texlab is reporting build errors when there shouldn't be, disable this option.
      '';
      keepLogs = mkBool true ''
        Keep the log files generated during processing.

        Without the keepLogs flag, texlab won't be able to report compilation warnings.
      '';
      onlyCached = mkBool false "Use only resource files cached locally";
      synctex = mkBool true "Generate SyncTeX data";
      untrustedInput = mkBool false "Input is untrusted -- disable all known-insecure features";

      # -- Options --
      reruns = mkOption {
        type = ints.unsigned;
        default = 0;
        example = 2;
        description = ''
          Rerun the TeX engine exactly this many times after the first.

          Setting this value to 0 will disable setting this option.
        '';
      };

      bundle = mkOption {
        type = str;
        default = "";
        description = "Use this directory or Zip-format bundle file to find resource files instead of the default";
      };

      webBundle = mkOption {
        type = str;
        default = "";
        description = "Use this URL to find resource files instead of the default";
      };

      outfmt = mkOption {
        type = enum [
          "pdf"
          "html"
          "xdv"
          "aux"
          "fmt"
          ""
        ];
        default = "";
        description = "The kind of output to generate";
      };

      hidePaths = mkOption {
        type = listOf str;
        default = [];
        example = [
          "./secrets.tex"
          "./passwords.tex"
        ];
        description = "Tell the engine that no file at <hide_path> exists, if it tries to read it.";
      };

      format = mkOption {
        type = str;
        default = "";
        description = "The name of the \"format\" file used to initialize the TeX engine";
      };

      color = mkOption {
        type = enum [
          "always"
          "auto"
          "never"
          ""
        ];
        default = "";
        example = "always";
        description = "Enable/disable colorful log output";
      };

      extraOptions = {
        type = listOf str;
        default = [];
        description = ''
          Add extra command line options to include in the tectonic build command.
          Extra options added here will not overwrite the options set in as nvf options.
        '';
      };
    };

    args = builderCfg: (
      # Base args
      [
        "-X"
        "compile"
        "%f"
      ]
      # Flags
      ++ (optionals builderCfg.keepIntermediates ["--keep-intermediates"])
      ++ (optionals builderCfg.keepLogs ["--keep-logs"])
      ++ (optionals builderCfg.onlyCached ["--only-cached"])
      ++ (optionals builderCfg.synctex ["--synctex"])
      ++ (optionals builderCfg.untrustedInput ["--untrusted"])
      # Options
      ++ (optionals (builderCfg.reruns > 0) ["--reruns" "${toString builderCfg.reruns}"])
      ++ (optionals (builderCfg.bundle != "") ["--bundle" "${toString builderCfg.bundle}"])
      ++ (optionals (builderCfg.webBundle != "") ["--web-bundle" "${toString builderCfg.webBundle}"])
      ++ (optionals (builderCfg.outfmt != "") ["--outfmt" "${toString builderCfg.outfmt}"])
      ++ (concatLists (map (x: ["--hide" x]) builderCfg.hidePaths))
      ++ (optionals (builderCfg.format != "") ["--format" "${toString builderCfg.format}"])
      ++ (optionals (builderCfg.color != "") ["--color" "${toString builderCfg.color}"])
      # Still options but these are not defined by builder specific options but
      # instead synchronize options between the global build options and builder
      # specific options
      ++ (optionals (!(elem cfg.build.pdfDirectory ["." ""])) ["--outdir" "${cfg.build.pdfDirectory}"])
    );
  }
)
