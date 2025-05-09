{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.lists) isList;
  inherit (lib.types) enum either listOf package str;
  inherit (lib.nvim.lua) expToLua;
  inherit (lib.nvim.types) diagnostics;

  cfg = config.vim.languages.sql;
  sqlfluffDefault = pkgs.sqlfluff;

  defaultServer = "sqls";
  servers = {
    sqls = {
      package = pkgs.sqls;
      lspConfig = ''
        lspconfig.sqls.setup {
          on_attach = function(client)
            client.server_capabilities.execute_command = true
            on_attach_keymaps(client, bufnr)
            require'sqls'.setup{}
          end,
          cmd = ${
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else ''{ "${cfg.lsp.package}/bin/sqls", "-config", string.format("%s/config.yml", vim.fn.getcwd()) }''
        }
        }
      '';
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

      package = mkOption {
        description = "SQL treesitter grammar to use";
        type = package;
        default = pkgs.vimPlugins.nvim-treesitter.builtGrammars.sql;
      };
    };

    lsp = {
      enable = mkEnableOption "SQL LSP support" // {default = config.vim.lsp.enable;};

      server = mkOption {
        description = "SQL LSP server to use";
        type = enum (attrNames servers);
        default = defaultServer;
      };

      package = mkOption {
        description = "SQL LSP server package, or the command to run as a list of strings";
        example = ''[lib.getExe pkgs.jdt-language-server "-data" "~/.cache/jdtls/workspace"]'';
        type = either package (listOf str);
        default = servers.${cfg.lsp.server}.package;
      };
    };

    format = {
      enable = mkEnableOption "SQL formatting" // {default = config.vim.languages.enableFormat;};

      type = mkOption {
        description = "SQL formatter to use";
        type = enum (attrNames formats);
        default = defaultFormat;
      };

      package = mkOption {
        description = "SQL formatter package";
        type = package;
        default = formats.${cfg.format.type}.package;
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
