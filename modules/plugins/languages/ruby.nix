{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib) genAttrs;
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.types) mkGrammarOption deprecatedSingleOrListOf enumWithRename;
  inherit (lib.types) enum listOf;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.ruby;

  defaultServers = ["solargraph"];
  servers = ["ruby-lsp" "solargraph" "stimulus-language-server"];

  # testing

  defaultFormat = ["rubocop"];
  formats = {
    rubocop = {
      command = getExe pkgs.rubyPackages.rubocop;
    };
  };

  defaultDiagnosticsProvider = ["rubocop"];
  diagnosticsProviders = ["rubocop"];
in {
  options.vim.languages.ruby = {
    enable = mkEnableOption "Ruby language support";

    treesitter = {
      enable =
        mkEnableOption "Ruby treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "ruby";
    };

    lsp = {
      enable =
        mkEnableOption "Ruby LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };

      servers = mkOption {
        type = listOf (enumWithRename
          "vim.languages.ruby.lsp.servers"
          servers
          {
            ruby_lsp = "ruby-lsp";
          });
        default = defaultServers;
        description = "Ruby LSP server to use";
      };
    };

    format = {
      enable = mkEnableOption "Ruby formatter support" // {default = config.vim.languages.enableFormat;};

      type = mkOption {
        type = deprecatedSingleOrListOf "vim.language.ruby.format.type" (enum (attrNames formats));
        default = defaultFormat;
        description = "Ruby formatter to use";
      };
    };

    extraDiagnostics = {
      enable =
        mkEnableOption "Ruby extra diagnostics via nvim-lint"
        // {default = config.vim.languages.enableExtraDiagnostics;};

      types = mkOption {
        type = listOf (enum diagnosticsProviders);
        default = defaultDiagnosticsProvider;
        description = "extra Ruby diagnostics providers";
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
        presets = genAttrs cfg.lsp.servers (_: {
          enable = [
            {
              value = true;
              src = ["vim" "languages" "ruby" "lsp" "servers"];
            }
          ];
        });
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = ["ruby" "eruby"];
        });
      };
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts = {
          formatters_by_ft.ruby = cfg.format.type;
          formatters =
            mapListToAttrs (name: {
              inherit name;
              value = formats.${name};
            })
            cfg.format.type;
        };
      };
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.diagnostics = {
        presets = genAttrs cfg.extraDiagnostics.types (_: {enable = true;});
        nvim-lint = {
          enable = true;
          linters_by_ft = {
            ruby = cfg.extraDiagnostics.types;
            eruby = cfg.extraDiagnostics.types;
          };
        };
      };
    })
  ]);
}
