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
  inherit (lib.options) mkOption mkEnableOption mkPackageOption;
  inherit (lib.types) enum ints listOf str nullOr;
  inherit (lib.nvim.config) mkBool;
  inherit (builtins) concatLists elem map toString attrNames filter isList;

  notNull = x: x != null;
  forceCheck = x: true;
  toList = x:
    if isList x
    then x
    else [x];

  cfg = config.vim.languages.tex;
in (
  template {
    inherit name moduleInheritancePackage;

    options = {
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
        Whether to diable all known-insecure features if the input is untrusted
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
          Use this directory or Zip-format bundle file to find resource files
          instead of the default.
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

      extraOptions = {
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

    # args = builderCfg: (
    #   # Base args
    #   [
    #     "-X"
    #     "compile"
    #     "%f"
    #   ]
    #   # Flags
    #   ++ (optionals builderCfg.keepIntermediates ["--keep-intermediates"])
    #   ++ (optionals builderCfg.keepLogs ["--keep-logs"])
    #   ++ (optionals builderCfg.onlyCached ["--only-cached"])
    #   ++ (optionals builderCfg.synctex ["--synctex"])
    #   ++ (optionals builderCfg.untrustedInput ["--untrusted"])
    #   # Options
    #   ++ (optionals (builderCfg.reruns > 0) ["--reruns" "${toString builderCfg.reruns}"])
    #   ++ (optionals (builderCfg.bundle != null) ["--bundle" "${toString builderCfg.bundle}"])
    #   ++ (optionals (builderCfg.webBundle != null) ["--web-bundle" "${toString builderCfg.webBundle}"])
    #   ++ (optionals (builderCfg.outfmt != null) ["--outfmt" "${toString builderCfg.outfmt}"])
    #   ++ (concatLists (map (x: ["--hide" x]) builderCfg.hidePaths))
    #   ++ (optionals (builderCfg.format != null) ["--format" "${toString builderCfg.format}"])
    #   ++ (optionals (builderCfg.color != null) ["--color" "${toString builderCfg.color}"])
    #   # Still options but these are not defined by builder specific options but
    #   # instead synchronize options between the global build options and builder
    #   # specific options
    #   ++ (optionals (!(elem cfg.build.pdfDirectory ["." ""])) ["--outdir" "${cfg.build.pdfDirectory}"])
    # );

    args = builderCfg: let
      option = setCheck: flag: {inherit setCheck flag;};
      args = {
        baseArgs = ["-X" "compile" "%f"];

        flags = {
          keepIntermediates = "--keep-intermediates";
          keepLogs = "--keep-logs";
          onlyCached = "--only-cached";
          synctex = "--synctex";
          untrustedInput = "--untrusted";
        };

        options = {
          reruns = option (x: x > 0) "--reruns";
          bundle = option notNull "--bundle";
          webBundle = option notNull "--web-bundle";
          outfmt = option notNull "--outfmt";
          format = option notNull "--format";
          color = option notNull "--color";
          hidePaths = option forceCheck "--hide";
        };

        externalOptions = concatLists [
          (optionals (!(elem cfg.build.pdfDirectory ["." ""])) ["--outdir" "${cfg.build.pdfDirectory}"])
        ];
      };

      flags = map (flag: args.flags.${flag}) (filter (flag: builderCfg.${flag}) (attrNames args.flags));
      options = let
        getOptionFlagsList = opt:
          concatLists (
            map
            (y: [args.options."${opt}".flag "${toString y}"])
            (toList builderCfg."${opt}")
          );
        processOption = opt:
          optionals
          (args.options."${opt}".setCheck builderCfg."${opt}")
          (getOptionFlagsList opt);
      in (concatLists (map processOption (attrNames args.options)));
    in
      concatLists (with args; [baseArgs flags options externalOptions]);
  }
)
