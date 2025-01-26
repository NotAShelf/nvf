{
  config,
  pkgs,
  lib,
  ...
} @ moduleInheritencePackage: let
  # The name of the builder
  name = "tectonic";

  # The builder template
  template = import ./builderTemplate.nix;

  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) enum ints listOf package str;
  inherit (lib.nvim.config) mkBool;
  inherit (builtins) concatLists elem map toString;

  cfg = config.vim.languages.tex;
in (
  template {
    inherit name moduleInheritencePackage;

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

          Setting this value to 0 will diable setting this option.
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
      ++ (
        if builderCfg.keepIntermediates
        then ["--keep-intermediates"]
        else []
      )
      ++ (
        if builderCfg.keepLogs
        then ["--keep-logs"]
        else []
      )
      ++ (
        if builderCfg.onlyCached
        then ["--only-cached"]
        else []
      )
      ++ (
        if builderCfg.synctex
        then ["--synctex"]
        else []
      )
      ++ (
        if builderCfg.untrustedInput
        then ["--untrusted"]
        else []
      )
      # Options
      ++ (
        if builderCfg.reruns > 0
        then ["--reruns" "${toString builderCfg.reruns}"]
        else []
      )
      ++ (
        if builderCfg.bundle != ""
        then ["--bundle" "${toString builderCfg.bundle}"]
        else []
      )
      ++ (
        if builderCfg.webBundle != ""
        then ["--web-bundle" "${toString builderCfg.webBundle}"]
        else []
      )
      ++ (
        if builderCfg.outfmt != ""
        then ["--outfmt" "${toString builderCfg.outfmt}"]
        else []
      )
      ++ (concatLists (map (x: ["--hide" x]) builderCfg.hidePaths))
      ++ (
        if builderCfg.format != ""
        then ["--format" "${toString builderCfg.format}"]
        else []
      )
      ++ (
        if builderCfg.color != ""
        then ["--color" "${toString builderCfg.color}"]
        else []
      )
      # Still options but these are not defined by builder specific options but
      # instead synchronize options between the global build options and builder
      # specific options
      ++ (
        if !(elem cfg.build.pdfDirectory ["." ""])
        then ["--outdir" "${cfg.build.pdfDirectory}"]
        else []
      )
    );
  }
)
