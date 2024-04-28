{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.lists) isList;
  inherit (lib.types) enum either listOf package str;
  inherit (lib.nvim.lua) expToLua;
  inherit (lib.nvim.languages) diagnosticsToLua;
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
      nullConfig = ''
        table.insert(
          ls_sources,
          null_ls.builtins.formatting.sqlfluff.with({
            command = "${cfg.format.package}/bin/sqlfluff",
            extra_args = {"--dialect", "${cfg.dialect}"}
          })
        )
      '';
    };
  };

  defaultDiagnosticsProvider = ["sqlfluff"];
  diagnosticsProviders = {
    sqlfluff = {
      package = sqlfluffDefault;
      nullConfig = pkg: ''
        table.insert(
          ls_sources,
          null_ls.builtins.diagnostics.sqlfluff.with({
            command = "${pkg}/bin/sqlfluff",
            extra_args = {"--dialect", "${cfg.dialect}"}
          })
        )
      '';
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
      enable = mkEnableOption "SQL LSP support" // {default = config.vim.languages.enableLSP;};

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
      vim.lsp.null-ls.enable = true;
      vim.lsp.null-ls.sources."sql-format" = formats.${cfg.format.type}.nullConfig;
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.lsp.null-ls.enable = true;
      vim.lsp.null-ls.sources = diagnosticsToLua {
        lang = "sql";
        config = cfg.extraDiagnostics.types;
        inherit diagnosticsProviders;
      };
    })
  ]);
}
