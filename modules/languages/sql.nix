{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
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
          cmd = { "${cfg.lsp.package}/bin/sqls", "-config", string.format("%s/config.yml", vim.fn.getcwd()) }
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

  defaultDiagnostics = ["sqlfluff"];
  diagnostics = {
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
      type = types.str;
      default = "ansi";
    };

    treesitter = {
      enable = mkOption {
        description = "Enable SQL treesitter";
        type = types.bool;
        default = config.vim.languages.enableTreesitter;
      };
      package = mkOption {
        description = "SQL treesitter grammar to use";
        type = types.package;
        default = pkgs.vimPlugins.nvim-treesitter.builtGrammars.sql;
      };
    };

    lsp = {
      enable = mkOption {
        description = "Enable SQL LSP support";
        type = types.bool;
        default = config.vim.languages.enableLSP;
      };
      server = mkOption {
        description = "SQL LSP server to use";
        type = with types; enum (attrNames servers);
        default = defaultServer;
      };
      package = mkOption {
        description = "SQL LSP server package";
        type = types.package;
        default = servers.${cfg.lsp.server}.package;
      };
    };

    format = {
      enable = mkOption {
        description = "Enable SQL formatting";
        type = types.bool;
        default = config.vim.languages.enableFormat;
      };
      type = mkOption {
        description = "SQL formatter to use";
        type = with types; enum (attrNames formats);
        default = defaultFormat;
      };
      package = mkOption {
        description = "SQL formatter package";
        type = types.package;
        default = formats.${cfg.format.type}.package;
      };
    };

    extraDiagnostics = {
      enable = mkOption {
        description = "Enable extra SQL diagnostics";
        type = types.bool;
        default = config.vim.languages.enableExtraDiagnostics;
      };
      types = lib.nvim.types.diagnostics {
        langDesc = "SQL";
        inherit diagnostics;
        inherit defaultDiagnostics;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.lsp.enable {
      vim.startPlugins = ["sqls-nvim"];

      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.sql-lsp = servers.${cfg.lsp.server}.lspConfig;
    })

    (mkIf cfg.format.enable {
      vim.lsp.null-ls.enable = true;
      vim.lsp.null-ls.sources."sql-format" = formats.${cfg.format.type}.nullConfig;
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.lsp.null-ls.enable = true;
      vim.lsp.null-ls.sources = lib.nvim.languages.diagnosticsToLua {
        lang = "sql";
        config = cfg.extraDiagnostics.types;
        inherit diagnostics;
      };
    })
  ]);
}
