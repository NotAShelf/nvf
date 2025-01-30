{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) listOf package str attrs ints enum either path nullOr submodule;
  inherit (lib.nvim.config) mkBool;
  inherit (builtins) isString map;

  cfg = config.vim.languages.tex;
  texlabCfg = cfg.lsp.texlab;
  builderCfg = cfg.build.builder;
in {
  options.vim.languages.tex.lsp.texlab = {
    enable = mkBool config.vim.languages.enableLSP "Whether to enable Tex LSP support (texlab)";

    package = mkOption {
      type = package;
      default = pkgs.texlab;
      description = "texlab package";
    };

    forwardSearch = {
      enable = mkBool false ''
        Whether to enable forward search.

        Enable this option if you want to have the compiled document appear in your chosen PDF viewer.

        For some options see [here](https://github.com/latex-lsp/texlab/wiki/Previewing).
        Note this is not all the options, but can act as a guide to help you allong with custom configs.
      '';

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

    diagnostics = {
      delay = mkOption {
        type = ints.positive;
        default = 300;
        description = "Delay in milliseconds before reporting diagnostics.";
      };

      allowedPatterns = mkOption {
        type = listOf str;
        default = [];
        description = ''
          A list of regular expressions used to filter the list of reported diagnostics.
          If specified, only diagnostics that match at least one of the specified patterns are sent to the client.

          See also texlab.diagnostics.ignoredPatterns.

          Hint: If both allowedPatterns and ignoredPatterns are set, then allowed patterns are applied first.
          Afterwards, the results are filtered with the ignored patterns.
        '';
      };

      ignoredPatterns = mkOption {
        type = listOf str;
        default = [];
        description = ''
          A list of regular expressions used to filter the list of reported diagnostics.
          If specified, only diagnostics that match none of the specified patterns are sent to the client.

          See also texlab.diagnostics.allowedPatterns.
        '';
      };
    };

    chktex = {
      enable = mkBool false "Whether to enable linting via chktex";

      package = mkOption {
        type = package;
        default = pkgs.texlive.withPackages (ps: [ps.chktex]);
        description = ''
          The chktex package to use.
          Must have the `chktex` executable.
        '';
      };

      onOpenAndSave = mkBool false "Lint using chktex after opening and saving a file.";

      onEdit = mkBool false "Lint using chktex after editing a file.";

      additionalArgs = mkOption {
        type = listOf str;
        default = [];
        description = ''
          Additional command line arguments that are passed to chktex after editing a file.
          Don't redefine the `-I` and `-f` flags as they are set by the server.
        '';
      };
    };

    symbols = {
      enable = mkBool false "Whether to enable setting symbols config.";

      allowedPatterns = mkOption {
        type = listOf str;
        default = [];
        description = ''
          A list of regular expressions used to filter the list of reported document symbols.
          If specified, only symbols that match at least one of the specified patterns are sent to the client.
          Symbols are filtered recursively so nested symbols can still be sent to the client even though the
          parent node is removed from the results.

          See also `texlab.symbols.ignoredPatterns`.

          Hint: If both allowedPatterns and ignoredPatterns are set, then allowed patterns are applied first.
          Afterwards, the results are filtered with the ignored patterns.
        '';
      };

      ignoredPatterns = mkOption {
        type = listOf str;
        default = [];
        description = ''
          A list of regular expressions used to filter the list of reported document symbols.
          If specified, only symbols that match none of the specified patterns are sent to the client.

          See also `texlab.symbols.allowedPatterns`.
        '';
      };

      customEnvironments = mkOption {
        type = listOf (submodule {
          options = {
            name = mkOption {
              type = str;
              description = "The name of the environment.";
            };
            displayName = mkOption {
              type = nullOr str;
              default = null;
              description = "The name shown in the document symbols. Defaults to the value of `name`.";
            };
            label = mkBool false ''
              If set, the server will try to match a label to environment and append its number.
            '';
          };
        });
        default = [];
        example = [
          {
            name = "foo";
            displayName = "bar";
            label = false;
          }
        ];
        description = ''
          A list of objects that allows extending the list of environments that are part of the document symbols.

          See also texlab.symbols.allowedPatterns.

          Type: listOf submodule:
            - name:
              - type: str
              - description: The name of the environment.
              - required
            - displayName:
              - type: nullOr str
              - description: The name shown in the document symbols.
              - default: <name>
            - label:
              - type: boolean
              - description: If set, the server will try to match a label to environment and append its number.
              - default: false

          Note: This functionallity may not be working, please follow https://github.com/latex-lsp/texlab/pull/1311
          for status updates.
        '';
      };
    };

    latexindent = {
      local = mkOption {
        type = nullOr (either str path);
        default = null;
        description = ''
          Defines the path of a file containing the latexindent configuration.
          This corresponds to the --local=file.yaml flag of latexindent.
          By default the configuration inside the project root directory is used.
        '';
      };

      modifyLineBreaks = mkBool false ''
        Modifies linebreaks before, during, and at the end of code blocks when formatting with latexindent.
        This corresponds to the --modifylinebreaks flag of latexindent.
      '';

      replacement = mkOption {
        type = nullOr (enum ["-r" "-rv" "-rr"]);
        default = null;
        description = ''
          Defines an additional replacement flag that is added when calling latexindent. This can be one of the following:
            - "-r"
            - "-rv"
            - "-rr"
            - null
          By default no replacement flag is passed.
        '';
      };
    };

    completion.matcher = mkOption {
      type = enum ["fuzzy" "fuzzy-ignore-case" "prefix" "prefix-ignore-case"];
      default = "fuzzy-ignore-case";
      description = ''
        Modifies the algorithm used to filter the completion items returned to the client. Possibles values are:
          - fuzzy: Fuzzy string matching (case sensitive)
          - fuzzy-ignore-case: Fuzzy string matching (case insensitive)
          - prefix: Filter out items that do not start with the search text (case sensitive)
          - prefix-ignore-case: Filter out items that do not start with the search text (case insensitive)
      '';
    };

    inlayHints = {
      labelDefinitions = mkBool true "When enabled, the server will return inlay hints for `\\label-like` commands.";

      labelReferences = mkBool true "When enabled, the server will return inlay hints for `\\ref``-like commands.";

      maxLength = mkOption {
        type = nullOr ints.positive;
        default = null;
        description = "When set, the server will truncate the text of the inlay hints to the specified length.";
      };
    };

    experimental = {
      followPackageLinks = mkBool false "If set to true, dependencies of custom packages are resolved and included in the dependency graph.";

      mathEnvironments = mkOption {
        type = listOf str;
        default = [];
        description = "Allows extending the list of environments which the server considers as math environments (for example `align*` or `equation`).";
      };

      enumEnvironments = mkOption {
        type = listOf str;
        default = [];
        description = "Allows extending the list of environments which the server considers as enumeration environments (for example `enumerate` or `itemize`).";
      };

      verbatimEnvironments = mkOption {
        type = listOf str;
        default = [];
        description = ''
          Allows extending the list of environments which the server considers as verbatim environments (for example `minted` or `lstlisting`).
          This can be used to suppress diagnostics from environments that do not contain LaTeX code.
        '';
      };

      citationCommands = mkOption {
        type = listOf str;
        default = [];
        description = ''
          Allows extending the list of commands which the server considers as citation commands (for example `\cite`).

          Hint: Additional commands need to be written without a leading `\` (e. g. `foo` instead of `\foo`).
        '';
      };
      labelDefinitionCommands = mkOption {
        type = listOf str;
        default = [];
        description = ''
          Allows extending the list of `\label`-like commands.

          Hint: Additional commands need to be written without a leading `\` (e. g. `foo` instead of `\foo`).
        '';
      };

      labelReferenceCommands = mkOption {
        type = listOf str;
        default = [];
        description = ''
          Allows extending the list of `\ref`-like commands.

          Hint: Additional commands need to be written without a leading `\` (e. g. `foo` instead of `\foo`).
        '';
      };

      labelReferenceRangeCommands = mkOption {
        type = listOf str;
        default = [];
        description = ''
          Allows extending the list of `\crefrange`-like commands.

          Hint: Additional commands need to be written without a leading `\` (e. g. `foo` instead of `\foo`).
        '';
      };

      labelDefinitionPrefixes = mkOption {
        type = listOf (listOf str);
        default = [];
        description = ''
          Allows associating a label definition command with a custom prefix. Consider,
          ```
          \newcommand{\thm}[1]{\label{thm:#1}}
          \thm{foo}
          ```
          Then setting `texlab.experimental.labelDefinitionPrefixes` to `[["thm", "thm:"]]` and adding "thm"
          to `texlab.experimental.labelDefinitionCommands` will make the server recognize the `thm:foo` label.
        '';
      };

      labelReferencePrefixes = mkOption {
        type = listOf (listOf str);
        default = [];
        description = ''
          Allows associating a label reference command with a custom prefix.
          See `texlab.experimental.labelDefinitionPrefixes` for more details.
        '';
      };
    };

    formatterLineLength = mkOption {
      type = ints.positive;
      default = 80;
      description = "Defines the maximum amount of characters per line (0 = disable) when formatting BibTeX files.";
    };

    bibtexFormatter = mkOption {
      type = enum ["texlab" "latexindent"];
      default = "texlab";
      description = ''
        Defines the formatter to use for BibTeX formatting.
        Possible values are either texlab or latexindent.
      '';
    };

    latexFormatter = mkOption {
      type = enum ["texlab" "latexindent"];
      default = "latexindent";
      description = ''
        Defines the formatter to use for LaTeX formatting.
        Possible values are either texlab or latexindent.
        Note that texlab is not implemented yet.
      '';
    };

    extraLuaSettings = mkOption {
      type = attrs;
      default = {};
      example = {
        foo = "bar";
        baz = 314;
      };
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

  config = mkIf cfg.enable (
    let
      # ----- Setup Config -----
      # Command to start the LSP
      setupConfig.cmd = ["${texlabCfg.package}/bin/texlab"];

      # Create texlab settings section
      setupConfig.settings.texlab = (
        {
          # -- General Settings --
          formatterLineLength = texlabCfg.formatterLineLength;

          # -- Formatters --
          bibtexFormatter = texlabCfg.bibtexFormatter;
          latexFormatter = texlabCfg.latexFormatter;

          # -- Diagnostics --
          diagnosticsDelay = texlabCfg.diagnostics.delay;
          diagnostics = {
            allowedPatterns = texlabCfg.diagnostics.allowedPatterns;
            ignoredPatterns = texlabCfg.diagnostics.ignoredPatterns;
          };

          # -- Latex Indent --
          latexindent = texlabCfg.latexindent;

          # -- Completion --
          completion.matcher = texlabCfg.completion.matcher;

          # -- Inlay Hints --
          inlayHints = texlabCfg.inlayHints;

          # -- Experimental --
          experimental = texlabCfg.experimental;
        }
        #
        # -- Forward Search --
        // (
          if texlabCfg.forwardSearch.enable
          then {
            forwardSearch = {
              executable = "${texlabCfg.forwardSearch.package}/bin/${texlabCfg.forwardSearch.executable}";
              args = texlabCfg.forwardSearch.args;
            };
          }
          else {}
        )
        #
        # -- Chktex --
        // (
          if texlabCfg.chktex.enable
          then {
            chktex = {
              inherit (texlabCfg.chktex) onOpenAndSave onEdit additionalArgs;
            };
          }
          else {}
        )
        #
        # -- Symbols --
        // (
          if texlabCfg.symbols.enable
          then {
            symbols = {
              inherit (texlabCfg.symbols) allowedPatterns ignoredPatterns;

              customEnvironments =
                map (x: {
                  inherit (x) name label;
                  displayName =
                    if isString x.displayName
                    then x.displayName
                    else x.name;
                })
                texlabCfg.symbols.customEnvironments;
            };
          }
          else {}
        )
        #
        # -- Build --
        // (
          if cfg.build.enable
          then {
            build = {
              executable = "${builderCfg.package}/bin/${builderCfg.executable}";
              args = builderCfg.args;
              forwardSearchAfter = cfg.build.forwardSearchAfter;
              onSave = cfg.build.onSave;
              useFileList = cfg.build.useFileList;
              auxDirectory = cfg.build.auxDirectory;
              logDirectory = cfg.build.logDirectory;
              pdfDirectory = cfg.build.pdfDirectory;
              filename = cfg.build.filename;
            };
          }
          else {}
        )
        #
        # -- Extra Settings --
        // texlabCfg.extraLuaSettings
      );
    in (mkMerge [
      (mkIf texlabCfg.enable {
        vim.lsp.lspconfig.sources.texlab = "lspconfig.texlab.setup(${lib.nvim.lua.toLuaObject setupConfig})";
      })

      (mkIf texlabCfg.chktex.enable {
        vim.extraPackages = [texlabCfg.chktex.package];
      })
    ])
  );
}
