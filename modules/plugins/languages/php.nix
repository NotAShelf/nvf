{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib) genAttrs;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.lists) flatten;
  inherit (lib.types) enum listOf;
  inherit (lib.nvim.types) mkGrammarOption enumWithRename;

  cfg = config.vim.languages.php;

  defaultServers = ["phpactor"];
  servers = ["phpactor" "phan" "intelephense" "phpantom"];

  defaultFormat = ["php-cs-fixer"];
  formats = ["php-cs-fixer"];

  defaultDiagnosticsProvider = ["phpstan"];
  diagnosticsProviders = ["phpstan"];

  defaultDebugger = ["xdebug"];
  dapConfigurations = {
    xdebug = let
      port = 9003;
    in [
      {
        type = "xdebug";
        request = "launch";
        name = "Listen for XDebug at port ${toString port}";
        inherit port;
      }
    ];
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
        type = listOf (enumWithRename
          "vim.languages.php.format.type"
          formats
          {
            php_cs_fixer = "php-cs-fixer";
          });
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

      debugger = mkOption {
        type = listOf (enum (attrNames dapConfigurations));
        default = defaultDebugger;
        description = "PHP debugger to use";
      };
    };

    extraDiagnostics = {
      enable =
        mkEnableOption "extra PHP diagnostics via nvim-lint"
        // {
          default = config.vim.languages.enableExtraDiagnostics;
          defaultText = literalExpression "config.vim.languages.enableExtraDiagnostics";
        };
      types = mkOption {
        type = listOf (enum diagnosticsProviders);
        default = defaultDiagnosticsProvider;
        description = "extra PHP diagnostics providers";
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
        presets = genAttrs cfg.format.type (_: {enable = true;});
        setupOpts.formatters_by_ft.php = cfg.format.type;
      };
    })

    (mkIf cfg.dap.enable {
      vim.debugger.nvim-dap = {
        enable = true;
        presets = genAttrs cfg.dap.debugger (_: {enable = true;});
        configurations.php = flatten (map (name: dapConfigurations.${name}) cfg.dap.debugger);
      };
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.diagnostics = {
        presets = genAttrs cfg.extraDiagnostics.types (_: {enable = true;});
        nvim-lint = {
          enable = true;
          linters_by_ft.php = cfg.extraDiagnostics.types;
        };
      };
    })
  ]);
}
