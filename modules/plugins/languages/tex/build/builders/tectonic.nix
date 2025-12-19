{
  config,
  lib,
  pkgs,
  ...
}: let
  # The name of the builder
  name = "tectonic";

  inherit (builtins) concatLists elem map toString match;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.config) mkBool;
  inherit (lib.options) mkOption mkEnableOption mkPackageOption;
  inherit (lib.strings) toLower optionalString stringAsChars;
  inherit (lib.types) enum ints listOf str nullOr;

  texCfg = config.vim.languages.tex;
  cfg = texCfg.build.builders.${name};
in {
  options.vim.languages.tex.build.builders.${name} = {
    enable = mkEnableOption "Tex Compilation Via Tectonic";

    package = mkPackageOption pkgs "tectonic" {};

    executable = mkOption {
      type = str;
      default = "tectonic";
      description = ''
        The executable name from the build package that will be used to
        build/compile the tex.
      '';
    };

    # -- Flags --
    keepIntermediates = mkBool false ''
      Whether to keep the intermediate files generated during processing.

      If texlab is reporting build errors when there shouldn't be, disable
      this option.
    '';
    keepLogs = mkBool true ''
      Whether to keep the log files generated during processing.

      Without the keepLogs flag, texlab won't be able to report compilation
      warnings.
    '';
    onlyCached = mkBool false ''
      Whether to use only resource files cached locally
    '';
    synctex = mkBool true "Whether to generate SyncTeX data";
    untrustedInput = mkBool false ''
      Whether to disable all known-insecure features if the input is untrusted
    '';

    # -- Options --
    reruns = mkOption {
      type = ints.unsigned;
      default = 0;
      example = 2;
      description = ''
        How many times to *rerun* the TeX build engine.
        The build engine (if a builder is enabled) will always run at least
        once.

        Setting this value to 0 will disable setting this option.
      '';
    };

    bundle = mkOption {
      type = nullOr str;
      default = null;
      description = ''
        The directory or Zip-format bundle file to find resource files instead
        of the default.
      '';
    };

    webBundle = mkOption {
      type = nullOr str;
      default = null;
      description = ''
        Use this URL to find resource files instead of the default.
      '';
    };

    outfmt = mkOption {
      type = nullOr (enum [
        "pdf"
        "html"
        "xdv"
        "aux"
        "fmt"
      ]);
      default = null;
      description = ''
        The kind of output to generate.

        Setting this to `null` (default) will let tectonic decide the most
        appropriate output format, which usually be a pdf.
      '';
    };

    hidePaths = mkOption {
      type = listOf str;
      default = [];
      example = [
        "./secrets.tex"
        "./passwords.tex"
      ];
      description = ''
        Tell the engine that no file at `<path/to/hide>` exists, if it tries
        to read it.
      '';
    };

    format = mkOption {
      type = nullOr str;
      default = null;
      description = ''
        The name of the \"format\" file used to initialize the TeX engine.
      '';
    };

    color = mkOption {
      type = nullOr (enum [
        "always"
        "auto"
        "never"
      ]);
      default = null;
      example = "always";
      description = "Enable/disable colorful log output";
    };

    extraOptions = mkOption {
      type = listOf str;
      default = [];
      description = ''
        Add extra command line options to include in the tectonic build
        command.
        Extra options added here will not overwrite the options set in as nvf
        options.
      '';
    };
  };

  config = mkIf (texCfg.enable && cfg.enable) {
    vim.languages.tex.build.builder = {
      inherit name;
      inherit (cfg) package executable;

      args = let
        inherit (lib.lists) optional optionals;
        snakeCaseToKebabCase = str: stringAsChars (x: "${optionalString ((match "[A-Z]" x) != null) "-"}${toLower x}") str;
        generateOptionFlag = option: (optionals (cfg.${option} != "" && cfg.${option} != null) ["--${snakeCaseToKebabCase option}" "${toString cfg.${option}}"]);
      in (
        # Base args
        [
          "-X"
          "compile"
          "%f"
        ]
        # Flags
        ++ (optional cfg.keepIntermediates "--keep-intermediates")
        ++ (optional cfg.keepLogs "--keep-logs")
        ++ (optional cfg.onlyCached "--only-cached")
        ++ (optional cfg.synctex "--synctex")
        ++ (optional cfg.untrustedInput "--untrusted")
        # Options
        ++ (optionals (cfg.reruns > 0) ["--reruns" "${toString cfg.reruns}"])
        ++ (generateOptionFlag "bundle")
        ++ (generateOptionFlag "webBundle")
        ++ (generateOptionFlag "outfmt")
        ++ (concatLists (map (x: ["--hide" x]) cfg.hidePaths))
        ++ (generateOptionFlag "format")
        ++ (generateOptionFlag "color")
        # Still options but these are not defined by builder specific options but
        # instead synchronize options between the global build options and builder
        # specific options.
        ++ (optionals (!(elem texCfg.build.pdfDirectory ["." ""])) ["--outdir" "${texCfg.build.pdfDirectory}"])
      );
    };
  };
}
