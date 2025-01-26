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
  inherit (lib.types) listOf package str;
  inherit
    (builtins)
    attrNames
    concatStringsSep
    elemAt
    filter
    hasAttr
    isAttrs
    length
    map
    throw
    toString
    ;
  inherit (lib.nvim.config) mkBool;

  cfg = config.vim.languages.tex;

  # --- Enable Options ---
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
      builder = cfg.build.builder;

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
        # This function will sort through the builder options and count how many
        # builders have been enabled.
        getEnabledBuildersCount = {
          enabledBuildersCount ? 0,
          index ? 0,
          builderNamesList ? (
            filter (
              x: let
                y = cfg.build.builders.${x};
              in (isAttrs y && hasAttr "enable" y)
            ) (attrNames cfg.build.builders)
          ),
        }: let
          currentBuilderName = elemAt builderNamesList index;
          currentBuilder = cfg.build.builders.${currentBuilderName};
          nextIndex = index + 1;
          newEnabledBuildersCount =
            if currentBuilder.enable
            then enabledBuildersCount + 1
            else enabledBuildersCount;
        in
          if length builderNamesList > nextIndex
          then
            getEnabledBuildersCount {
              inherit builderNamesList;
              enabledBuildersCount = newEnabledBuildersCount;
              index = nextIndex;
            }
          else newEnabledBuildersCount;

        enabledBuildersCount = getEnabledBuildersCount {};
      in
        if enabledBuildersCount == 0
        then ""
        else if enabledBuildersCount > 1
        then throw "Texlab does not support having more than 1 builders enabled!"
        else ''
          build = {
                  executable = "${builder.package}/bin/${builder.executable}",
                  args = ${listToLua builder.args false},
                  forwardSearchAfter = ${boolToLua cfg.build.forwardSearchAfter},
                  onSave = ${boolToLua cfg.build.onSave},
                  useFileList = ${boolToLua cfg.build.useFileList},
                  auxDirectory = ${stringToLua cfg.build.auxDirectory true},
                  logDirectory = ${stringToLua cfg.build.logDirectory true},
                  pdfDirectory = ${stringToLua cfg.build.pdfDirectory true},
                  filename = ${stringToLua cfg.build.filename true},
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
