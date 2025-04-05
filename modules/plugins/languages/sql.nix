{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) isList attrNames;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) enum either listOf package str;
  inherit (lib.meta) getExe;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.languages) lspOptions;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.types) diagnostics mkGrammarOption;

  cfg = config.vim.languages.sql;
  sqlfluffDefault = pkgs.sqlfluff;

  defaultServer = "sqls";
  servers = {
    sqls = {
      package = pkgs.sqls;
      options = {
        on_attach = mkLuaInline ''
          function(client)
            on_attach_keymaps(client, bufnr)
            client.server_capabilities.execute_command = true
            require('sqls').setup()
          end,
        '';

        cmd =
          if isList cfg.lsp.package
          then toLuaObject cfg.lsp.package
          else ''{ "${cfg.lsp.package}/bin/sqls", "-config", string.format("%s/config.yml", vim.fn.getcwd()) }'';
      };
    };
  };

  defaultFormat = "sqlfluff";
  formats = {
    sqlfluff = {
      package = sqlfluffDefault;
      config = {
        command = getExe cfg.format.package;
        append_args = ["--dialect=${cfg.dialect}"];
      };
    };
  };

  defaultDiagnosticsProvider = ["sqlfluff"];
  diagnosticsProviders = {
    sqlfluff = {
      package = sqlfluffDefault;
      config = {
        cmd = getExe sqlfluffDefault;
        args = ["lint" "--format=json" "--dialect=${cfg.dialect}"];
      };
    };
  };
in {
  options.vim.languages.sql = {
    enable = mkEnableOption "SQL language support";

    dialect = mkOption {
      description = "SQL dialect for sqlfluff (if used)";
      type = str;
      default = "ansi";
    };

    treesitter = {
      enable = mkEnableOption "SQL treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption "sql";
    };

    lsp = {
      enable = mkEnableOption "SQL LSP support" // {default = config.vim.languages.enableLSP;};
      server = mkOption {
        type = listOf (enum (attrNames servers));
        default = defaultServer;
        description = "SQL LSP server to use";
      };

      package = mkOption {
        type = either package (listOf str);
        example = ''[lib.getExe pkgs.jdt-language-server "-data" "~/.cache/jdtls/workspace"]'';
        default = servers.${cfg.lsp.server}.package;
        description = "SQL LSP server package, or the command to run as a list of strings";
      };
    };

    format = {
      enable = mkEnableOption "SQL formatting" // {default = config.vim.languages.enableFormat;};
      type = mkOption {
        type = enum (attrNames formats);
        default = defaultFormat;
        description = "SQL formatter to use";
      };

      package = mkOption {
        type = package;
        default = formats.${cfg.format.type}.package;
        description = "SQL formatter package";
      };
    };

    extraDiagnostics = {
      enable = mkEnableOption "extra SQL diagnostics" // {default = config.vim.languages.enableExtraDiagnostics;};
      types = diagnostics {
        langDesc = "SQL";
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
      vim = {
        startPlugins = ["sqls-nvim"];

        lsp.lspconfig = {
          enable = true;
          sources.sql-lsp = servers.${cfg.lsp.server}.lspConfig;
        };
      };
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts.formatters_by_ft.sql = [cfg.format.type];
        setupOpts.formatters.${cfg.format.type} = formats.${cfg.format.type}.config;
      };
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.diagnostics.nvim-lint = {
        enable = true;
        linters_by_ft.sql = cfg.extraDiagnostics.types;
        linters =
          mkMerge (map (name: {${name} = diagnosticsProviders.${name}.config;})
            cfg.extraDiagnostics.types);
      };
    })
  ]);
}
