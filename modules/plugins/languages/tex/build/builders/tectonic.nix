{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.modules) mkIf;
  inherit
    (lib.types)
    bool
    enum
    ints
    listOf
    package
    str
    ;
  inherit
    (builtins)
    attrNames
    concatLists
    concatStringsSep
    elem
    elemAt
    filter
    hasAttr
    isAttrs
    length
    map
    throw
    toString
    ;

  cfg = config.vim.languages.tex;

  # --- Enable Options ---
  mkEnableDefaultOption = default: description: (mkOption {
    type = bool;
    default = default;
    example = !default;
    description = description;
  });
  mkEnableLspOption = mkEnableDefaultOption config.vim.languages.enableLSP;

  # --- Arg Collation Functions --
  collateArgs = buildConfig: let
    selfConfig = buildConfig.builders.tectonic;
  in (
    # Base args
    [
      "-X"
      "compile"
      "%f"
    ]
    # Flags
    ++ (
      if selfConfig.keepIntermediates
      then ["--keep-intermediates"]
      else []
    )
    ++ (
      if selfConfig.keepLogs
      then ["--keep-logs"]
      else []
    )
    ++ (
      if selfConfig.onlyCached
      then ["--only-cached"]
      else []
    )
    ++ (
      if selfConfig.synctex
      then ["--synctex"]
      else []
    )
    ++ (
      if selfConfig.untrustedInput
      then ["--untrusted"]
      else []
    )
    # Options
    ++ (
      if selfConfig.reruns > 0
      then ["--reruns" "${toString selfConfig.reruns}"]
      else []
    )
    ++ (
      if selfConfig.bundle != ""
      then ["--bundle" "${toString selfConfig.bundle}"]
      else []
    )
    ++ (
      if selfConfig.webBundle != ""
      then ["--web-bundle" "${toString selfConfig.webBundle}"]
      else []
    )
    ++ (
      if selfConfig.outfmt != ""
      then ["--outfmt" "${toString selfConfig.outfmt}"]
      else []
    )
    ++ (concatLists (map (x: ["--hide" x]) selfConfig.hidePaths))
    ++ (
      if selfConfig.format != ""
      then ["--format" "${toString selfConfig.format}"]
      else []
    )
    ++ (
      if selfConfig.color != ""
      then ["--color" "${toString selfConfig.color}"]
      else []
    )
    # Still options but these are not defined by builder specific options but
    # instead synchronize options between the global build options and builder
    # specific options
    ++ (
      if !(elem buildConfig.pdfDirectory ["." ""])
      then ["--outdir" "${buildConfig.pdfDirectory}"]
      else []
    )
  );
in {
  options.vim.languages.tex.build.builders.tectonic = {
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
    keepIntermediates = mkEnableDefaultOption false ''
      Keep the intermediate files generated during processing.

      If texlab is reporting build errors when there shouldn't be, disable this option.
    '';
    keepLogs = mkEnableDefaultOption true ''
      Keep the log files generated during processing.

      Without the keepLogs flag, texlab won't be able to report compilation warnings.
    '';
    onlyCached = mkEnableDefaultOption false "Use only resource files cached locally";
    synctex = mkEnableDefaultOption true "Generate SyncTeX data";
    untrustedInput = mkEnableDefaultOption false "Input is untrusted -- disable all known-insecure features";

    # -- Options --
    reruns = mkOption {
      type = ints.unsigned;
      default = 0;
      example = 2;
      description = "Rerun the TeX engine exactly this many times after the first";
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

  config = mkIf (cfg.enable && cfg.build.builders.tectonic.enable) {
    vim.languages.tex.build.builder = {
      name = "tectonic";
      args = collateArgs cfg.build;
      package = cfg.build.builders.tectonic.package;
    };
  };
}
