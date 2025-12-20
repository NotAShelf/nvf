{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) getExe;
  inherit (lib.attrsets) optionalAttrs attrNames hasAttrByPath;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.nvim.types) deprecatedSingleOrListOf;
  inherit (lib.types) enum;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.tex;
  builderCfg = cfg.build.builder;

  pdfViewer = cfg.pdfViewer.viewers.${cfg.pdfViewer.name};

  # **===========================================**
  # ||          <<<<< LSP SERVERS >>>>>          ||
  # **===========================================**

  defaultServers = ["texlab"];

  servers = {
    texlab = {
      cmd = [(getExe pkgs.texlab)];
      filetypes = ["tex" "plaintex" "context"];
      root_markers = [".git"];
      capabilities = {
        settings.texlab = (
          {
            # -- Completion --
            completion.matcher = "fuzzy-ignore-case";

            # -- Diagnostics --
            diagnosticsDelay = 300;

            # -- Formatters --
            formatterLineLength = 80;
            bibtexFormatter = "texlab";
            latexFormatter = "latexindent";

            # -- Inlay Hints --
            inlayHints = {
              labelDefinitions = true;
              labelReferences = true;
            };
          }
          #
          # -- Build --
          // (optionalAttrs cfg.build.enable {
            build = {
              inherit
                (cfg.build)
                onSave
                useFileList
                auxDirectory
                logDirectory
                pdfDirectory
                filename
                forwardSearchAfter
                ;
              inherit (builderCfg) args;
              executable = with builderCfg; "${package}/bin/${executable}";
            };
          })
          #
          # -- Forward Search --
          // (optionalAttrs (cfg.pdfViewer.enable) {
            forwardSearch = {
              inherit (pdfViewer) args;
              executable = with pdfViewer; "${package}/bin/${executable}";
            };
          })
        );
      };
    };
  };
in {
  options.vim.languages.tex.lsp = {
    enable = mkEnableOption "TeX LSP support" // {default = config.vim.lsp.enable;};

    servers = mkOption {
      description = "The TeX LSP servers to use";
      type = deprecatedSingleOrListOf "vim.language.tex.lsp.servers" (enum (attrNames servers));
      default = defaultServers;
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.lsp.enable {
      vim.lsp.servers =
        mapListToAttrs (name: {
          inherit name;
          value = servers.${name};
        })
        cfg.lsp.servers;
    })

    # Add the chktex package when texlab has config is set that requires it.
    (mkIf (hasAttrByPath ["texlab" "capabilities" "settings" "chktex"] cfg.lsp.servers) {
      vim.extraPackages = [(pkgs.texlive.withPackages (ps: [ps.chktex]))];
    })
  ]);
}
