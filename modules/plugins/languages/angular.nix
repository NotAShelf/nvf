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
  inherit (lib.meta) getExe;
  inherit (lib.types) enum either listOf package str;
  inherit (lib.nvim.lua) expToLua;
  inherit (lib.nvim.types) mkGrammarOption diagnostics;

  cfg = config.vim.languages.angular;

  defaultServer = "angular";
  servers = {
    angular = {
      package = pkgs.angular-language-server;
      lspConfig = ''
        lspconfig.angularls.setup {
          capabilities = capabilities,
          on_attach = attach_keymaps,
          cmd = ${
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else ''{"${cfg.lsp.package}/bin/ngserver", "--stdio"}''
        }
        }
      '';
    };
  };

  # TODO: specify packages
  defaultFormat = "prettier";
  formats = {
    prettier = {
      package = pkgs.prettier;
    };

    prettierd = {
      package = pkgs.prettierd;
    };

    biome = {
      package = pkgs.biome;
    };
  };

  # TODO: specify packages
  defaultDiagnosticsProvider = ["eslint_d"];
  diagnosticsProviders = {
    eslint_d = let
      pkg = pkgs.eslint_d;
    in {
      package = pkg;
      config = {
        cmd = getExe pkg;
        required_files = [
          "eslint.config.js"
          "eslint.config.mjs"
          ".eslintrc"
          ".eslintrc.json"
          ".eslintrc.js"
          ".eslintrc.yml"
        ];
      };
    };
  };
in {
  options.vim.languages.angular = {
    enable = mkEnableOption "Angular framework support";

    treesitter = {
      enable = mkEnableOption "Angular treesitter" // {default = config.vim.languages.enableTreesitter;};

      angularPackage = mkGrammarOption pkgs "angular";
    };

    lsp = {
      enable = mkEnableOption "Angular LSP support" // {default = config.vim.lsp.enable;};

      server = mkOption {
        type = enum (attrNames servers);
        default = defaultServer;
        description = "Angular LSP server to use";
      };

      package = mkOption {
        type = either package (listOf str);
        default = servers.${cfg.lsp.server}.package;
        example = ''[lib.getExe pkgs.angular-language-server "--stdio"]'';
        description = "Angular LSP server package, or the command to run as a list of strings";
      };
    };

    format = {
      enable = mkEnableOption "Angular formatting" // {default = config.vim.languages.enableFormat;};

      type = mkOption {
        description = "Angular formatter to use";
        type = enum (attrNames formats);
        default = defaultFormat;
      };

      package = mkOption {
        description = "Angular formatter package";
        type = package;
        default = formats.${cfg.format.type}.package;
      };
    };

    extraDiagnostics = {
      enable = mkEnableOption "extra Angular diagnostics" // {default = config.vim.languages.enableExtraDiagnostics;};

      types = diagnostics {
        langDesc = "Angular";
        inherit diagnosticsProviders;
        inherit defaultDiagnosticsProvider;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.angularPackage];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.angular-lsp = servers.${cfg.lsp.server}.lspConfig;
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts.formatters_by_ft.angular = [cfg.format.type];
        setupOpts.formatters.${cfg.format.type} = {
          command = getExe cfg.format.package;
        };
      };
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.diagnostics.nvim-lint = {
        enable = true;
        linters_by_ft.angular = cfg.extraDiagnostics.types;
        linters =
          mkMerge (map (name: {${name} = diagnosticsProviders.${name}.config;})
            cfg.extraDiagnostics.types);
      };
    })
  ]);
}
