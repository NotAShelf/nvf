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
}:
let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) package str bool listOf;
  inherit (lib.nvim.types) mkGrammarOption;
  inherit (builtins) any attrValues;

  cfg = config.vim.languages.tex;
in
{
  options.vim.languages.tex = {
    enable = mkEnableOption "Tex support";

    # Treesitter options for latex and bibtex flavours of tex.
    treesitter = {
      latex = {
        enable = mkEnableOption "Latex treesitter" // {
          default = config.vim.languages.enableTreesitter;
        };
        package = mkGrammarOption pkgs "latex";
      };
      bibtex = {
        enable = mkEnableOption "Bibtex treesitter" // {
          default = config.vim.languages.enableTreesitter;
        };
        package = mkGrammarOption pkgs "bibtex";
      };
    };

    # LSP options
    # Because tex LSPs also including building/compiling tex, they have
    # more options that are only specific to them and thus it makes
    # more sense to group one into its own group of options.
    #
    # Each lsp group must have an enable option of its own.
    lsp = {
      texlab = {
        enable = mkEnableOption "Tex LSP support (texlab)" // {
          default = config.vim.languages.enableLSP;
        };

        package = mkOption {
          type = package;
          default = pkgs.texlab;
          description = "texlab package";
        };

        build = {
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
            default = null;
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

      # Add other LSPs here

    };
  };

  config = mkIf cfg.enable (mkMerge [

    # Treesitter
    (mkIf cfg.treesitter.latex.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [ cfg.treesitter.latex.package ];
    })
    (mkIf cfg.treesitter.bibtex.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [ cfg.treesitter.bibtex.package ];
    })

    # LSP
    (mkIf (any (x: x.enable) (attrValues cfg.lsp)) (
      {
        vim.lsp.lspconfig.enable = true; # Enable lspconfig when any of the lsps are enabled
      }
      // (mkMerge [

        # Texlab
        (
          let
            tl = cfg.lsp.texlab;
            build = tl.build;
            listToLua =
              list: nullOnEmpty:
              let
                inherit (builtins)
                  length
                  concatStringsSep
                  map
                  toString
                  ;
              in
              if length list == 0 then
                if nullOnEmpty then "null" else "{ }"
              else
                "{ ${concatStringsSep ", " (map (x: ''"${toString x}"'') list)} }";
          in
          (mkIf tl.enable {
            vim.lsp.lspconfig.sources.texlab = ''
              lspconfig.texlab.setup {
                settings = {
                  texlab = {
                    build = {
                      executable = "${build.package}/bin/${build.executable}",
                      args = ${listToLua build.args false},
                      forwardSearchAfter = ${build.forwardSearchAfter},
                      onSave = ${build.onSave},
                      useFileList = ${build.useFileList},
                      auxDirectory = "${build.auxDirectroy}",
                      logDirectory = "${build.logDirectroy}",
                      pdfDirectory = "${build.pdfDirectroy}",
                      ${if build.filename != null then ''filename = "${build.filename}",'' else ""}
                    },
                    forwardSearch = {
                      executable = "${tl.forwardSearch.package}/bin/${tl.forwardSearch.executable}",
                      args = ${listToLua tl.forwardSearch.args true}
                    },
                    ${tl.extraLuaSettings}
                  }
                }
              }
            '';
          })
        )

        # Add other LSPs here
      ])
    ))

  ]);
}
