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
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit
    (lib.types)
    bool
    listOf
    package
    str
    ;
  inherit (lib.nvim.types) mkGrammarOption;
  inherit
    (builtins)
    any
    attrValues
    concatStringsSep
    length
    map
    toString
    ;

  cfg = config.vim.languages.tex;
in {
  options.vim.languages.tex = {
    enable = mkEnableOption "Tex support";

    # Treesitter options for latex and bibtex flavours of tex.
    treesitter = {
      latex = {
        enable = mkEnableOption "Latex treesitter" // { default = config.vim.languages.enableTreesitter; };
        package = mkGrammarOption pkgs "latex";
      };
      bibtex = {
        enable = mkEnableOption "Bibtex treesitter" // { default = config.vim.languages.enableTreesitter; };
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
        enable = mkEnableOption "Tex LSP support (texlab)" // { default = config.vim.languages.enableLSP; };

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

      # Add other LSPs here
    };

    extraOpts = {
      texFlavor = {
        enable = mkOption {
          type = bool;
          default = false;
          example = true;
          description = ''
            Whether to set the vim.g.tex_flavor (g:tex_flavor) option in your lua config.

            When opening a .tex file vim will try to automatically try to determine the file type from
            the three options: plaintex (for plain TeX), context (for ConTeXt), or tex (for LaTeX).
            This can either be done by a indicator line of the form `%&<format>` on the first line or
            if absent vim will search the file for keywords to try and determine the filetype.
            If no filetype can be determined automatically then by default it will fallback to plaintex.

            This option will enable setting the tex flavor in your lua config and you can set its value
            useing the `vim.languages.tex.lsp.extraOpts.texFlavor.flavor = <flavor>` in your nvf config.

            Setting this option to `false` will omit the `vim.g.tex_flavor = <flavor>` line from your lua
            config entirely (unless you manually set it elsewhere of course).
          '';
        };
        flavor = mkOption {
          type = str;
          default = "plaintex";
          example = "tex";
          description = ''
            The flavor to set as a fallback for when vim cannot automatically determine the tex flavor when
            opening a .tex document.

            The options are: plaintex (for plain TeX), context (for ConTeXt), or tex (for LaTeX).

            This can be particularly useful for when using `vim.utility.new-file-template` options for
            creating templates when no context has yet been added to a new file.
          '';
        };
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    # Treesitter
    (mkIf cfg.treesitter.latex.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.latex.package];
    })
    (mkIf cfg.treesitter.bibtex.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.bibtex.package];
    })

    # LSP
    (mkIf (any (x: x.enable) (attrValues cfg.lsp)) (
      { vim.lsp.lspconfig.enable = true; } # Enable lspconfig when any of the lsps are enabled
      // (mkMerge [
        # Texlab
        (
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

          in (mkIf tl.enable {
            vim.lsp.lspconfig.sources.texlab = ''
              lspconfig.texlab.setup {
                cmd = { "${tl.package}/bin/texlab" },
                settings = {
                  texlab = {
                    build = {
                      executable = "${build.package}/bin/${build.executable}",
                      args = ${listToLua build.args false},
                      forwardSearchAfter = ${boolToLua build.forwardSearchAfter},
                      onSave = ${boolToLua build.onSave},
                      useFileList = ${boolToLua build.useFileList},
                      auxDirectory = ${stringToLua build.auxDirectory true},
                      logDirectory = ${stringToLua build.logDirectory true},
                      pdfDirectory = ${stringToLua build.pdfDirectory true},
                      filename = ${stringToLua build.filename true},
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

    # Extra Lua config options
    (mkIf cfg.extraOpts.texFlavor.enable {
      vim.globals.tex_flavor = "${cfg.extraOpts.texFlavor.flavor}";
    })
  ]);
}
