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
  inherit (lib.types) enum package str;
  inherit (lib.nvim.types) diagnostics singleOrListOf;
  inherit (lib.nvim.attrsets) mapListToAttrs;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.languages.sql;
  sqlfluffDefault = pkgs.sqlfluff;

  defaultServers = ["sqls"];
  servers = {
    sqls = {
      enable = true;
      cmd = [(getExe pkgs.sqls)];
      filetypes = ["sql" "mysql"];
      root_markers = ["config.yml"];
      settings = {};
      on_attach = mkLuaInline ''
        function(client, bufnr)
          client.server_capabilities.execute_command = true
          require'sqls'.setup{}
        end
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
      type = str;
      default = "ansi";
      description = "SQL dialect for sqlfluff (if used)";
    };

    treesitter = {
      enable = mkEnableOption "SQL treesitter" // {default = config.vim.languages.enableTreesitter;};

      package = mkOption {
        type = package;
        default = pkgs.vimPlugins.nvim-treesitter.builtGrammars.sql;
        description = "SQL treesitter grammar to use";
      };
    };

    lsp = {
      enable = mkEnableOption "SQL LSP support" // {default = config.vim.lsp.enable;};

      servers = mkOption {
        type = singleOrListOf (enum (attrNames servers));
        default = defaultServers;
        description = "SQL LSP server to use";
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

        lsp.servers =
          mapListToAttrs (n: {
            name = n;
            value = servers.${n};
          })
          cfg.lsp.servers;
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
