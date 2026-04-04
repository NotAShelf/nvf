{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) literalExpression mkEnableOption mkOption;
  inherit (lib.types) bool enum listOf;
  inherit (lib.nvim.types) mkGrammarOption;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.tex;
  defaultServers = ["texlab"];
  servers = {
    texlab = {
      enable = true;
      cmd = [(getExe pkgs.texlab) "run"];
      filetypes = ["plaintex" "tex" "bib"];
      root_markers = [".git" ".latexmkrc" "latexmkrc" ".texlabroot" "texlabroot" ".texstudio" "Tectonic.toml"];
    };
  };

  defaultFormat = ["tex-fmt"];
  formats = {
    tex-fmt = {
      command = getExe pkgs.tex-fmt;
    };
    latexindent = {
      command = "${pkgs.texlive.withPackages (ps: [ps.latexindent])}/bin/latexindent";
    };
  };
in {
  options.vim.languages.tex = {
    enable = mkEnableOption "TeX language support";

    treesitter = {
      enable = mkOption {
        type = bool;
        default = config.vim.languages.enableTreesitter;
        defaultText = literalExpression "config.vim.languages.enableTreesitter";
        description = "Enable TeX treesitter";
      };
      latexPackage = mkGrammarOption pkgs "latex";
      bibtexPackage = mkGrammarOption pkgs "bibtex";
    };

    lsp = {
      enable =
        mkEnableOption "TeX LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };

      servers = mkOption {
        description = "TeX LSP server to use";
        type = listOf (enum (attrNames servers));
        default = defaultServers;
      };
    };

    format = {
      enable =
        mkEnableOption "TeX formatting"
        // {
          default = config.vim.languages.enableFormat;
          defaultText = literalExpression "config.vim.languages.enableFormat";
        };

      type = mkOption {
        type = listOf (enum (attrNames formats));
        default = defaultFormat;
        description = "TeX formatter to use";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [
        cfg.treesitter.latexPackage
        cfg.treesitter.bibtexPackage
      ];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.servers =
        mapListToAttrs (n: {
          name = n;
          value = servers.${n};
        })
        cfg.lsp.servers;
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts = {
          formatters_by_ft.tex = cfg.format.type;
          formatters_by_ft.plaintex = cfg.format.type;
          formatters =
            mapListToAttrs (name: {
              inherit name;
              value = formats.${name};
            })
            cfg.format.type;
        };
      };
    })
  ]);
}
