# TODO:
# - Add Texlab LSP settings:
#   - chktex
#   - diagnosticsDelay
#   - diagnostics
#   - symbols
#   - formatterLineLength
#   - bibtexFormatter
#   - latexFormatter
#   - latexindent
#   - completion
#   - inlayHints
#   - experimental
{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkOption;
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
  collateArgs.lsp.texlab.build = {
    tectonic = buildConfig: let
      selfConfig = buildConfig.tectonic;
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
    custom = buildConfig: buildConfig.custom.args;
  };
in {
  options.vim.languages.tex.lsp.texlab = {
    enable = mkEnableLspOption "Whether to enable Tex LSP support (texlab)";

    package = mkOption {
      type = package;
      default = pkgs.texlab;
      description = "texlab package";
    };

    build = {
      tectonic = {
        enable = mkEnableDefaultOption true "Whether to enable Tex Compilation Via Tectonic";

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

      custom = {
        enable = mkEnableDefaultOption false "Whether to enable using a custom build package";
        package = mkOption {
          type = package;
          default = pkgs.tectonic;
          description = "build/compiler package";
        };
        executable = mkOption {
          type = str;
          default = "tectonic";
          description = "The executable name from the build package that will be used to build/compile the tex.";
        };
        args = mkOption {
          type = listOf str;
          default = [
            "-X"
            "compile"
            "%f"
            "--synctex"
            "--keep-logs"
            "--keep-intermediates"
          ];
          description = ''
            Defines additional arguments that are passed to the configured LaTeX build tool.
            Note that flags and their arguments need to be separate elements in this array.
            To pass the arguments -foo bar to a build tool, args needs to be ["-foo" "bar"].
            The placeholder `%f` will be replaced by the server.

            Placeholders:
              - `%f`: The path of the TeX file to compile.
          '';
        };
      };

      forwardSearchAfter = mkOption {
        type = bool;
        default = false;
        description = "Set this property to true if you want to execute a forward search after a build.";
      };
      onSave = mkOption {
        type = bool;
        default = false;
        description = "Set this property to true if you want to compile the project after saving a file.";
      };
      useFileList = mkOption {
        type = bool;
        default = false;
        description = ''
          When set to true, the server will use the .fls files produced by the TeX engine as an additional input for the project detection.

          Note that enabling this property might have an impact on performance.
        '';
      };
      auxDirectory = mkOption {
        type = str;
        default = ".";
        description = ''
          When not using latexmk, provides a way to define the directory containing the .aux files.
          Note that you need to set the aux directory in latex.build.args too.

          When using a latexmkrc file, texlab will automatically infer the correct setting.
        '';
      };
      logDirectory = mkOption {
        type = str;
        default = ".";
        description = ''
          When not using latexmk, provides a way to define the directory containing the build log files.
          Note that you need to change the output directory in your build arguments too.

          When using a latexmkrc file, texlab will automatically infer the correct setting.
        '';
      };
      pdfDirectory = mkOption {
        type = str;
        default = ".";
        description = ''
          When not using latexmk, provides a way to define the directory containing the output files.
          Note that you need to set the output directory in latex.build.args too.

          When using a latexmkrc file, texlab will automatically infer the correct setting.
        '';
      };
      filename = mkOption {
        type = str;
        default = "";
        description = ''
          Allows overriding the default file name of the build artifact. This setting is used to find the correct PDF file to open during forward search.
        '';
      };
    };

    forwardSearch = {
      enable = mkOption {
        type = bool;
        default = false;
        example = true;
        description = ''
          Whether to enable forward search.

          Enable this option if you want to have the compiled document appear in your chosen PDF viewer.

          For some options see [here](https://github.com/latex-lsp/texlab/wiki/Previewing).
          Note this is not all the options, but can act as a guide to help you allong with custom configs.
        '';
      };
      package = mkOption {
        type = package;
        default = pkgs.okular;
        description = ''
          The package to use as your PDF viewer.
          This viewer needs to support Synctex.
        '';
      };
      executable = mkOption {
        type = str;
        default = "okular";
        description = ''
          Defines the executable of the PDF previewer. The previewer needs to support SyncTeX.
        '';
      };
      args = mkOption {
        type = listOf str;
        default = [
          "--unique"
          "file:%p#src:%l%f"
        ];
        description = ''
          Defines additional arguments that are passed to the configured previewer to perform the forward search.
          The placeholders %f, %p, %l will be replaced by the server.

          Placeholders:
            - %f: The path of the current TeX file.
            - %p: The path of the current PDF file.
            - %l: The current line number.
        '';
      };
    };

    extraLuaSettings = mkOption {
      type = str;
      default = "";
      example = ''
        formatterLineLength = 80,
      '';
      description = ''
        For any options that do not have options provided through nvf this can be used to add them.
        Options already declared in nvf config will NOT be overridden.

        Options will be placed in:
        ```
        lspconfig.texlab.setup {
          settings = {
            texlab = {
              ...
              <nvf defined options>
              ...
              <extraLuaSettings>
            }
          }
        }
        ```
      '';
    };
  };

  config = mkIf (cfg.enable && (cfg.lsp.texlab.enable)) (
    let
      tl = cfg.lsp.texlab;
      build = tl.build;

      listToLua = list: nullOnEmpty:
        if length list == 0
        then
          if nullOnEmpty
          then "null"
          else "{ }"
        else "{ ${concatStringsSep ", " (map (x: ''"${toString x}"'') list)} }";

      stringToLua = string: nullOnEmpty:
        if string == ""
        then
          if nullOnEmpty
          then "null"
          else ""
        else ''"${string}"'';

      boolToLua = boolean:
        if boolean
        then "true"
        else "false";

      # -- Build --
      buildConfig = let
        # This function will sort through the builder options of ...texlab.build and count how many
        # builders have been enabled and get the attrs of the last enabled builder.
        getBuilder = {
          enabledBuildersCount ? 0,
          enabledBuilderName ? "",
          index ? 0,
          builderNamesList ? (
            filter (
              x: let
                y = tl.build.${x};
              in (isAttrs y && hasAttr "enable" y)
            ) (attrNames tl.build)
          ),
        }: let
          currentBuilderName = elemAt builderNamesList index;
          currentBuilder = tl.build.${currentBuilderName};
          nextIndex = index + 1;
          currentState = {
            enabledBuildersCount =
              if currentBuilder.enable
              then enabledBuildersCount + 1
              else enabledBuildersCount;
            enabledBuilderName =
              if currentBuilder.enable
              then currentBuilderName
              else enabledBuilderName;
          };
        in
          if length builderNamesList > nextIndex
          then
            getBuilder ({
                inherit builderNamesList;
                index = nextIndex;
              }
              // currentState)
          else currentState;

        getBuilderResults = getBuilder {};
        builder = tl.build.${getBuilderResults.enabledBuilderName};
        builderArgs = collateArgs.lsp.texlab.build.${getBuilderResults.enabledBuilderName} tl.build;
      in
        if getBuilderResults.enabledBuildersCount == 0
        then ""
        else if getBuilderResults.enabledBuildersCount > 1
        then throw "Texlab does not support having more than 1 builders enabled!"
        else ''
          build = {
                  executable = "${builder.package}/bin/${builder.executable}",
                  args = ${listToLua builderArgs false},
                  forwardSearchAfter = ${boolToLua build.forwardSearchAfter},
                  onSave = ${boolToLua build.onSave},
                  useFileList = ${boolToLua build.useFileList},
                  auxDirectory = ${stringToLua build.auxDirectory true},
                  logDirectory = ${stringToLua build.logDirectory true},
                  pdfDirectory = ${stringToLua build.pdfDirectory true},
                  filename = ${stringToLua build.filename true},
                },
        '';
    in {
      vim.lsp.lspconfig.sources.texlab = ''
        lspconfig.texlab.setup {
          cmd = { "${tl.package}/bin/texlab" },
          settings = {
            texlab = {
              ${buildConfig}
              forwardSearch = {
                executable = "${tl.forwardSearch.package}/bin/${tl.forwardSearch.executable}",
                args = ${listToLua tl.forwardSearch.args true}
              },
              ${tl.extraLuaSettings}
            }
          }
        }
      '';
    }
  );
}
