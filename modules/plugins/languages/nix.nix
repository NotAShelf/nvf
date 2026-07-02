{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) concatStringsSep genAttrs elem;
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) enum listOf;
  inherit (lib.nvim.types) mkGrammarOption deprecatedSingleOrListOf;

  cfg = config.vim.languages.nix;

  defaultServers = ["nil"];
  servers = ["nil" "nixd"];

  defaultFormat = ["alejandra"];
  formats = ["alejandra" "nixfmt" "nixfmt-rs"];

  defaultDiagnosticsProvider = ["statix" "deadnix"];
  diagnosticsProviders = ["statix" "deadnix"];
in {
  options.vim.languages.nix = {
    enable = mkEnableOption "Nix language support";

    treesitter = {
      enable =
        mkEnableOption "Nix treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "nix";
    };

    lsp = {
      enable =
        mkEnableOption "Nix LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };
      servers = mkOption {
        type = listOf (enum servers);
        default = defaultServers;
        description = "Nix LSP server to use";
      };
    };

    format = {
      enable =
        mkEnableOption "Nix formatting"
        // {
          default = config.vim.languages.enableFormat;
          defaultText = literalExpression "config.vim.languages.enableFormat";
        };

      type = mkOption {
        description = "Nix formatter to use";
        type = deprecatedSingleOrListOf "vim.language.nix.format.type" (enum formats);
        default = defaultFormat;
      };
    };

    extraDiagnostics = {
      enable =
        mkEnableOption "extra Nix diagnostics via nvim-lint"
        // {
          default = config.vim.languages.enableExtraDiagnostics;
          defaultText = literalExpression "config.vim.languages.enableExtraDiagnostics";
        };

      types = mkOption {
        type = listOf (enum diagnosticsProviders);
        default = defaultDiagnosticsProvider;
        description = "extra Nix diagnostics providers";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      assertions = [
        {
          assertion = !(elem "nixpkgs-fmt" cfg.format.type);
          message = ''
            nixpkgs-fmt has been archived upstream. Please use one of the following available formatters:
            ${concatStringsSep ", " formats}
          '';
        }
      ];
    }

    (mkIf cfg.treesitter.enable {
      vim.treesitter = {
        enable = true;
        grammars = [cfg.treesitter.package];
        queries = [
          # query = ''; -> query
          {
            type = "injections";
            filetypes = ["nix"];
            query = ''
              ;; extends

              ((binding
                attrpath: (attrpath
                  (identifier) @_path)
                  (#eq? @_path "query")
                expression: [
                  (string_expression
                    ((string_fragment) @injection.content
                    (#set! injection.language "query")))
                  (indented_string_expression
                    ((string_fragment) @injection.content
                    (#set! injection.language "query")))
                  (apply_expression
                    argument: [
                      (string_expression
                        ((string_fragment) @injection.content
                        (#set! injection.language "query")))
                      (indented_string_expression
                        ((string_fragment) @injection.content
                        (#set! injection.language "query")))
                    ])
                ]))
            '';
          }
          # mkLuaInline, entryAnywhere, entryBefore, entryAfter -> lua
          {
            type = "injections";
            filetypes = ["nix"];
            query = ''
              ;; extends

              ((apply_expression
                function: (variable_expression
                  name: (identifier) @_func
                  (#any-of? @_func "mkLuaInline" "entryAnywhere"))
                argument: (indented_string_expression
                  (string_fragment) @injection.content))
              (#set! injection.language "lua")
              (#set! injection.combined))

              ((apply_expression
                function: (apply_expression
                  function: (variable_expression
                    name: (identifier) @_func
                    (#any-of? @_func "entryBefore" "entryAfter"))
                  argument: (_))
                argument: (indented_string_expression
                  (string_fragment) @injection.content))
              (#set! injection.language "lua")
              (#set! injection.combined))
            '';
          }
        ];
      };
    })

    (mkIf cfg.lsp.enable {
      vim.lsp = {
        presets = genAttrs cfg.lsp.servers (_: {enable = true;});
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = ["nix"];
          root_markers = ["flake.nix"];
        });
      };
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        presets = genAttrs cfg.format.type (_: {enable = true;});
        setupOpts.formatters_by_ft.nix = cfg.format.type;
      };
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.diagnostics = {
        presets = genAttrs cfg.extraDiagnostics.types (_: {enable = true;});
        nvim-lint = {
          enable = true;
          linters_by_ft.nix = cfg.extraDiagnostics.types;
        };
      };
    })
  ]);
}
