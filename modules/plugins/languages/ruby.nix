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
  inherit (lib.nvim.types) mkGrammarOption diagnostics;
  inherit (lib.types) either listOf package str enum;

  cfg = config.vim.languages.ruby;

  defaultServer = "rubyserver";
  servers = {
    rubyserver = {
      package = pkgs.rubyPackages.solargraph;
      lspConfig = ''
        lspconfig.solargraph.setup {
          capabilities = capabilities,
          on_attach = attach_keymaps,
          flags = {
            debounce_text_changes = 150,
          },
          cmd = { "${pkgs.solargraph}/bin/solargraph", "stdio" }
        }
      '';
    };
  };

  # testing

  defaultFormat = "rubocop";
  formats = {
    rubocop = {
      # TODO: is this right?
      package = pkgs.rubyPackages.rubocop;
    };
  };

  defaultDiagnosticsProvider = ["rubocop"];
  diagnosticsProviders = {
    rubocop = {
      package = pkgs.rubyPackages.rubocop;
      config.command = getExe cfg.format.package;
    };
  };
in {
  options.vim.languages.ruby = {
    enable = mkEnableOption "Ruby language support";

    treesitter = {
      enable = mkEnableOption "Ruby treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "ruby";
    };

    lsp = {
      enable = mkEnableOption "Ruby LSP support" // {default = config.vim.languages.enableLSP;};

      server = mkOption {
        type = enum (attrNames servers);
        default = defaultServer;
        description = "Ruby LSP server to use";
      };

      package = mkOption {
        type = either package (listOf str);
        default = servers.${cfg.lsp.server}.package;
        description = "Ruby LSP server package, or the command to run as a list of strings";
      };
    };

    format = {
      enable = mkEnableOption "Ruby formatter support" // {default = config.vim.languages.enableFormat;};

      type = mkOption {
        type = enum (attrNames formats);
        default = defaultFormat;
        description = "Ruby formatter to use";
      };

      package = mkOption {
        type = package;
        default = formats.${cfg.format.type}.package;
        description = "Ruby formatter package";
      };
    };

    extraDiagnostics = {
      enable =
        mkEnableOption "Ruby extra diagnostics support"
        // {default = config.vim.languages.enableExtraDiagnostics;};

      types = diagnostics {
        langDesc = "Ruby";
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
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.ruby-lsp = servers.${cfg.lsp.server}.lspConfig;
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts.formatters_by_ft.ruby = [cfg.format.type];
        setupOpts.formatters.${cfg.format.type} = {
          command = getExe cfg.format.package;
        };
      };
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.diagnostics.nvim-lint = {
        enable = true;
        linters_by_ft.ruby = cfg.extraDiagnostics.types;
        linters = mkMerge (map (name: {
            ${name}.cmd = getExe diagnosticsProviders.${name}.package;
          })
          cfg.extraDiagnostics.types);
      };
    })
  ]);
}
