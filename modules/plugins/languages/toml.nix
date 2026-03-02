{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) enum;
  inherit (lib.nvim.types) diagnostics mkGrammarOption deprecatedSingleOrListOf;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.toml;
  defaultServers = ["taplo"];
  servers = {
    tombi = {
      enable = true;
      cmd = [
        (getExe pkgs.tombi)
        "lsp"
      ];
      filetypes = ["toml"];
      root_markers = [
        "tombi.toml"
        ".git"
      ];
    };
    taplo = {
      enable = true;
      cmd = [
        (getExe pkgs.taplo)
        "lsp"
        "stdio"
      ];
      filetypes = ["toml"];
      root_markers = [
        ".git"
      ];
    };
  };

  defaultFormat = ["taplo"];
  formats = {
    tombi = {
      command = getExe pkgs.tombi;
      args = [
        "format"
        "--stdin-filepath"
        "$FILENAME"
        "-"
      ];
    };
    taplo = {
      command = getExe pkgs.taplo;
      args = [
        "format"
        "--stdin-filepath"
        "$FILENAME"
        "-"
      ];
    };
  };
  defaultDiagnosticsProvider = ["tombi"];
  diagnosticsProviders = {
    tombi = {
      package = pkgs.tombi;
      args = ["lint"];
    };
  };
in {
  options.vim.languages.toml = {
    enable = mkEnableOption "TOML configuration language support";

    treesitter = {
      enable =
        mkEnableOption "TOML treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
        };
      package = mkGrammarOption pkgs "toml";
    };

    lsp = {
      enable =
        mkEnableOption "TOML LSP support"
        // {
          default = config.vim.lsp.enable;
        };

      servers = mkOption {
        description = "TOML LSP server to use";
        type = deprecatedSingleOrListOf "vim.language.toml.lsp.servers" (enum (attrNames servers));
        default = defaultServers;
      };
    };

    format = {
      enable =
        mkEnableOption "TOML formatting"
        // {
          default = config.vim.languages.enableFormat;
        };

      type = mkOption {
        type = deprecatedSingleOrListOf "vim.language.toml.format.type" (enum (attrNames formats));
        default = defaultFormat;
        description = "TOML formatter to use.";
      };
    };

    extraDiagnostics = {
      enable =
        mkEnableOption "extra TOML diagnostics"
        // {
          default = config.vim.languages.enableExtraDiagnostics;
        };
      types = diagnostics {
        langDesc = "TOML";
        inherit diagnosticsProviders;
        inherit defaultDiagnosticsProvider;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [
        cfg.treesitter.package
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
          formatters_by_ft.toml = cfg.format.type;
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
        linters_by_ft.toml = cfg.extraDiagnostics.types;
        linters = mkMerge (
          map (name: {
            ${name}.cmd = getExe diagnosticsProviders.${name}.package;
          })
          cfg.extraDiagnostics.types
        );
      };
    })
  ]);
}
