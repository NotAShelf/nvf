{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames toString;
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib) genAttrs;
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) enum int attrs listOf;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.types) mkGrammarOption diagnostics;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.php;

  defaultServers = ["phpactor"];
  servers = ["phpactor" "phan" "intelephense"];

  defaultFormat = ["php_cs_fixer"];
  formats = {
    php_cs_fixer = {
      /*
      Using 8.4 instead of 8.5 because of compatibility:
      ```logs
      2026-02-08 00:42:23[ERROR] Formatter 'php_cs_fixer' error: PHP CS Fixer 3.87.2
      PHP runtime: 8.5.2
      PHP CS Fixer currently supports PHP syntax only up to PHP 8.4, current PHP version: 8.5.2.
      ```
      */
      command = "${pkgs.php84Packages.php-cs-fixer}/bin/php-cs-fixer";
    };
  };

  defaultDiagnosticsProvider = ["phpstan"];

  diagnosticsProviders = {
    phpstan = {
      config.cmd = getExe pkgs.phpstan;
    };
  };
in {
  options.vim.languages.php = {
    enable = mkEnableOption "PHP language support";

    treesitter = {
      enable =
        mkEnableOption "PHP treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "php";
    };

    lsp = {
      enable =
        mkEnableOption "PHP LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };

      servers = mkOption {
        type = listOf (enum servers);
        default = defaultServers;
        description = "PHP LSP server to use";
      };
    };

    format = {
      enable =
        mkEnableOption "PHP formatting"
        // {
          default = config.vim.languages.enableFormat;
          defaultText = literalExpression "config.vim.languages.enableFormat";
        };

      type = mkOption {
        description = "PHP formatter to use";
        type = listOf (enum (attrNames formats));
        default = defaultFormat;
      };
    };

    dap = {
      enable =
        mkEnableOption "Enable PHP Debug Adapter"
        // {
          default = config.vim.languages.enableDAP;
          defaultText = literalExpression "config.vim.languages.enableDAP";
        };
      xdebug = {
        adapter = mkOption {
          type = attrs;
          default = {
            type = "executable";
            command = getExe pkgs.nodejs;
            args = [
              "${pkgs.vscode-extensions.xdebug.php-debug}/share/vscode/extensions/xdebug.php-debug/out/phpDebug.js"
            ];
          };
          description = "XDebug adapter to use for nvim-dap";
        };
        port = mkOption {
          type = int;
          default = 9003;
          description = "Port to use for XDebug";
        };
      };
    };

    extraDiagnostics = {
      enable =
        mkEnableOption "extra PHP diagnostics"
        // {
          default = config.vim.languages.enableExtraDiagnostics;
          defaultText = literalExpression "config.vim.languages.enableExtraDiagnostic";
        };

      types = diagnostics {
        langDesc = "PHP";
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
      vim.lsp = {
        presets = genAttrs cfg.lsp.servers (_: {enable = true;});
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = ["php"];
          root_markers = ["composer.json"];
        });
      };
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts = {
          formatters_by_ft.php = cfg.format.type;
          formatters =
            mapListToAttrs (name: {
              inherit name;
              value = formats.${name};
            })
            cfg.format.type;
        };
      };
    })

    (mkIf cfg.dap.enable {
      vim = {
        debugger.nvim-dap = {
          enable = true;
          sources.php-debugger = ''
            dap.adapters.xdebug = ${toLuaObject cfg.dap.xdebug.adapter}
            dap.configurations.php = {
              {
                  type = 'xdebug',
                  request = 'launch',
                  name = 'Listen for XDebug',
                  port = ${toString cfg.dap.xdebug.port},
              },
            }
          '';
        };
      };
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.diagnostics.nvim-lint = {
        enable = true;
        linters_by_ft.php = cfg.extraDiagnostics.types;
        linters =
          mkMerge (map (name: {${name} = diagnosticsProviders.${name}.config;})
            cfg.extraDiagnostics.types);
      };
    })
  ]);
}
