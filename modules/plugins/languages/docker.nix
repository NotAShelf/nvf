{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib) genAttrs;
  inherit (lib.meta) getExe;
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) enum listOf;
  inherit (lib.nvim.types) mkGrammarOption diagnostics;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.docker;

  defaultServers = ["docker-language-server"];
  servers = ["docker-language-server"];

  defaultFormat = ["dockerfmt"];
  formats = {
    dockerfmt = {
      command = getExe pkgs.dockerfmt;
    };
  };

  defaultDiagnosticsProvider = ["hadolint"];
  diagnosticsProviders = {
    hadolint = {
      config.cmd = getExe (
        pkgs.writeShellApplication {
          name = "hadolint";
          runtimeInputs = [pkgs.hadolint];
          text = "hadolint -";
        }
      );
    };
  };
in {
  options.vim.languages.docker = {
    enable = mkEnableOption "Docker language support";
    treesitter = {
      enable =
        mkEnableOption "Docker treesitter support"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "dockerfile";
    };

    lsp = {
      enable =
        mkEnableOption "Docker LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };
      servers = mkOption {
        type = listOf (enum servers);
        default = defaultServers;
        description = "Docker LSP server to use";
      };
    };

    format = {
      enable =
        mkEnableOption "Dockerfile formatting"
        // {
          default = config.vim.languages.enableFormat;
          defaultText = literalExpression "config.vim.languages.enableFormat";
        };

      type = mkOption {
        type = listOf (enum (attrNames formats));
        default = defaultFormat;
        description = "Dockerfile formatter to use";
      };
    };

    extraDiagnostics = {
      enable =
        mkEnableOption "extra Dockerfile diagnostics"
        // {
          default = config.vim.languages.enableExtraDiagnostics;
        };

      types = diagnostics {
        langDesc = "Dockerfile";
        inherit diagnosticsProviders;
        inherit defaultDiagnosticsProvider;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      vim.autocmds = [
        # Without this the LSP doesn't understand them correctly
        # and there are conflicts with the YAML LSP
        {
          desc = "Set Docker Compose filetype";
          event = ["BufRead" "BufNewFile"];
          pattern = [
            "compose.yml"
            "compose.yaml"
            "docker-compose.yml"
            "docker-compose.yaml"
          ];
          command = "set filetype=dockercompose";
        }
      ];
    }

    (mkIf cfg.treesitter.enable {
      vim.treesitter = {
        enable = true;
        grammars = [cfg.treesitter.package];
      };
    })

    (mkIf cfg.lsp.enable {
      vim.lsp = {
        presets = genAttrs cfg.lsp.servers (_: {enable = true;});
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = [
            "dockerfile"
            "dockercompose"
          ];
        });
      };
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts = {
          formatters_by_ft.dockerfile = cfg.format.type;
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
        linters_by_ft.dockerfile = cfg.extraDiagnostics.types;
        linters = mkMerge (
          map (name: {
            ${name} = diagnosticsProviders.${name}.config;
          })
          cfg.extraDiagnostics.types
        );
      };
    })
  ]);
}
