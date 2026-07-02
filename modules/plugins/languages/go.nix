{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption literalMD literalExpression;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.meta) getExe;
  inherit (lib) genAttrs;
  inherit (lib.types) enum package str listOf;
  inherit (lib.nvim.types) mkGrammarOption deprecatedSingleOrListOf mkPluginSetupOption;
  inherit (lib.nvim.dag) entryAfter;

  cfg = config.vim.languages.go;

  defaultServers = ["gopls"];
  servers = ["gopls"];

  defaultFormat = ["gofmt"];
  formats = ["gofmt" "gofumpt" "golines" "goimports"];

  defaultDebugger = "delve";
  debuggers = {
    delve = {
      package = pkgs.delve;
    };
  };

  defaultDiagnosticsProvider = ["golangci-lint"];
  diagnosticsProviders = ["golangci-lint"];
in {
  options.vim.languages.go = {
    enable = mkEnableOption "Go language support";

    treesitter = {
      enable =
        mkEnableOption "Go treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };

      goPackage = mkGrammarOption pkgs "go";
      gomodPackage = mkGrammarOption pkgs "gomod";
      gosumPackage = mkGrammarOption pkgs "gosum";
      goworkPackage = mkGrammarOption pkgs "gowork";
      gotmpl = {
        package = mkGrammarOption pkgs "gotmpl";
        injection = mkOption {
          type = str;
          default = "html";
          description = "Treesitter language to inject in Go templates";
        };
      };
    };

    lsp = {
      enable =
        mkEnableOption "Go LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };

      servers = mkOption {
        type = listOf (enum servers);
        default = defaultServers;
        description = "Go LSP server to use";
      };
    };

    format = {
      enable =
        mkEnableOption "Go formatting"
        // {
          default = !cfg.lsp.enable && config.vim.languages.enableFormat;
          defaultText = literalMD ''
            disabled if Go LSP is enabled, otherwise follows {option}`vim.languages.enableFormat`
          '';
        };

      type = mkOption {
        type = deprecatedSingleOrListOf "vim.language.go.format.type" (enum formats);
        default = defaultFormat;
        description = "Go formatter to use";
      };
    };

    dap = {
      enable =
        mkEnableOption "Go Debug Adapter"
        // {
          default = config.vim.languages.enableDAP;
          defaultText = literalExpression "config.vim.languages.enableDAP";
        };

      debugger = mkOption {
        type = enum (attrNames debuggers);
        default = defaultDebugger;
        description = "Go debugger to use";
      };

      package = mkOption {
        type = package;
        default = debuggers.${cfg.dap.debugger}.package;
        description = "Go debugger package.";
      };
    };

    extraDiagnostics = {
      enable =
        mkEnableOption "extra Go diagnostics via nvim-lint"
        // {
          default = config.vim.languages.enableExtraDiagnostics;
          defaultText = literalExpression "config.vim.languages.enableExtraDiagnostic";
        };

      types = mkOption {
        type = listOf (enum diagnosticsProviders);
        default = defaultDiagnosticsProvider;
        description = "extra Go diagnostics providers";
      };
    };

    extensions = {
      gopher-nvim = {
        enable = mkEnableOption "Minimalistic plugin for Go development";
        setupOpts = mkPluginSetupOption "gopher-nvim" {
          commands = {
            go = mkOption {
              type = str;
              default = "go";
              description = "Go binary to use";
            };

            gomodifytags = mkOption {
              type = str;
              default = getExe pkgs.gomodifytags;
              defaultText = literalExpression "getExe pkgs.gomodifytags";
              description = "gomodifytags binary to use";
            };

            gotests = mkOption {
              type = str;
              default = getExe pkgs.gotests;
              defaultText = literalExpression "getExe pkgs.gotests";
              description = "gotests binary to use";
            };

            impl = mkOption {
              type = str;
              default = getExe pkgs.impl;
              defaultText = literalExpression "getExe pkgs.impl";
              description = "impl binary to use";
            };

            iferr = mkOption {
              type = str;
              default = getExe pkgs.iferr;
              defaultText = literalExpression "getExe pkgs.iferr";
              description = "iferr binary to use";
            };

            json2go = mkOption {
              type = str;
              default = getExe inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.json2go;
              defaultText = literalExpression "getExe inputs.self.packages.$${pkgs.stdenv.hostPlatform.system}.json2go";
              description = "json2go binary to use";
            };
          };
        };
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      vim.filetype.extension = {
        gohtml = "gotmpl";
        tmpl = "gotmpl";
      };
    }

    (mkIf cfg.treesitter.enable {
      vim.treesitter = {
        enable = true;
        grammars = [
          cfg.treesitter.goPackage
          cfg.treesitter.gomodPackage
          cfg.treesitter.gosumPackage
          cfg.treesitter.goworkPackage
          cfg.treesitter.gotmpl.package
        ];
        queries = [
          {
            type = "injections";
            filetypes = ["gotmpl"];
            query = ''
              ;; extends

              ((text) @injection.content
                (#set! injection.language "${cfg.treesitter.gotmpl.injection}")
                (#set! injection.combined)
              )
            '';
          }
        ];
      };
    })

    (mkIf cfg.lsp.enable {
      vim.lsp = {
        presets = genAttrs cfg.lsp.servers (_: {enable = true;});
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = ["go" "gomod" "gosum" "gowork" "gotmpl"];
        });
      };
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        presets = genAttrs cfg.format.type (_: {enable = true;});
        setupOpts.formatters_by_ft.go = cfg.format.type;
      };
    })

    (mkIf cfg.dap.enable {
      vim = {
        startPlugins = ["nvim-dap-go"];
        pluginRC.nvim-dap-go = entryAfter ["nvim-dap"] ''
          require('dap-go').setup {
            delve = {
              path = '${getExe cfg.dap.package}',
            }
          }
        '';
        debugger.nvim-dap.enable = true;
      };
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.diagnostics = {
        presets = genAttrs cfg.extraDiagnostics.types (_: {enable = true;});
        nvim-lint = {
          enable = true;
          linters_by_ft.go = cfg.extraDiagnostics.types;
        };
      };
    })

    (mkIf cfg.extensions.gopher-nvim.enable {
      vim.lazy.plugins.gopher-nvim = {
        package = "gopher-nvim";
        setupModule = "gopher";
        inherit (cfg.extensions.gopher-nvim) setupOpts;
        ft = ["go"];
      };
    })
  ]);
}
