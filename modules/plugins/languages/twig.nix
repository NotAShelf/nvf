{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.meta) getExe;
  inherit (lib.types) listOf enum;
  inherit (lib.nvim.types) mkGrammarOption diagnostics;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.twig;

  defaultServers = ["twig-language-server"];
  servers = {
    twig-language-server = {
      enable = true;
      cmd = [(getExe pkgs.twig-language-server) "--stdio"];
      filetypes = ["twig"];
      root_markers = [".git"];
    };
  };

  defaultFormat = ["djlint"];
  formats = {
    djlint = {
      command = getExe pkgs.djlint;
    };
    # TODO: if twig-cs-fixer gets packaged for nix, add it and default to it.
  };
  defaultDiagnosticsProvider = ["djlint"];
  diagnosticsProviders = {
    djlint = {
      config = {
        cmd = getExe pkgs.djlint;
      };
    };
    # TODO: if curlylint gets packaged for nix, add it.
  };
in {
  options.vim.languages.twig = {
    enable = mkEnableOption "Twig templating language support";

    treesitter = {
      enable = mkEnableOption "Twig treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "twig";
    };

    lsp = {
      enable = mkEnableOption "Twig LSP support" // {default = config.vim.lsp.enable;};
      servers = mkOption {
        type = listOf (enum (attrNames servers));
        default = defaultServers;
        description = "Twig LSP server to use";
      };
    };

    format = {
      enable = mkEnableOption "PHP formatting" // {default = config.vim.languages.enableFormat;};
      type = mkOption {
        description = "Twig formatter to use";
        type = listOf (enum (attrNames formats));
        default = defaultFormat;
      };
    };

    extraDiagnostics = {
      enable = mkEnableOption "extra Twig diagnostics" // {default = config.vim.languages.enableExtraDiagnostics;};
      types = diagnostics {
        langDesc = "Twig";
        inherit diagnosticsProviders;
        inherit defaultDiagnosticsProvider;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
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
          formatters_by_ft.twig = cfg.format.type;
          formatters =
            mapListToAttrs (name: {
              inherit name;
              value = formats.${name};
            })
            cfg.format.type;
        };
      };
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.diagnostics.nvim-lint = {
        enable = true;
        linters_by_ft.twig = cfg.extraDiagnostics.types;
        linters =
          mkMerge (map (name: {${name} = diagnosticsProviders.${name}.config;})
            cfg.extraDiagnostics.types);
      };
    })
  ]);
}
