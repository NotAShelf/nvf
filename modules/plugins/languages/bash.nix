{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption literalExpression;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) enum bool listOf;
  inherit (lib) genAttrs;
  inherit (lib.nvim.types) mkGrammarOption deprecatedSingleOrListOf enumWithRename;

  cfg = config.vim.languages.bash;

  defaultServers = ["bash-language-server"];
  servers = ["bash-language-server"];

  defaultFormat = ["shfmt"];
  formats = ["shfmt"];

  defaultDiagnosticsProvider = ["shellcheck"];
  diagnosticsProviders = ["shellcheck"];
in {
  options.vim.languages.bash = {
    enable = mkEnableOption "Bash language support";

    treesitter = {
      enable =
        mkEnableOption "Bash treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "bash";
    };

    lsp = {
      enable =
        mkEnableOption "Bash LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };
      servers = mkOption {
        type = listOf (enumWithRename
          "vim.languages.bash.lsp.servers"
          servers
          {
            bash-ls = "bash-language-server";
          });
        default = defaultServers;
        description = "Bash LSP server to use";
      };
    };

    format = {
      enable = mkOption {
        type = bool;
        default = config.vim.languages.enableFormat;
        defaultText = literalExpression "config.vim.languages.enableFormat";
        description = "Enable Bash formatting";
      };
      type = mkOption {
        type = deprecatedSingleOrListOf "vim.language.bash.format.type" (enum formats);
        default = defaultFormat;
        description = "Bash formatter to use";
      };
    };

    extraDiagnostics = {
      enable =
        mkEnableOption "extra Shell diagnostics via nvim-lint"
        // {
          default = config.vim.languages.enableExtraDiagnostics;
          defaultText = literalExpression "config.vim.languages.enableExtraDiagnostics";
        };

      types = mkOption {
        type = listOf (enum diagnosticsProviders);
        default = defaultDiagnosticsProvider;
        description = "extra Shell diagnostics providers";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter = {
        enable = true;
        grammars = [cfg.treesitter.package];
        # not perfect mappings, but better than none
        filetypeMappings.bash = ["ash" "dash" "zsh"];
      };
    })

    (mkIf cfg.lsp.enable {
      vim.lsp = {
        presets = genAttrs cfg.lsp.servers (_: {enable = true;});
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = ["bash" "sh" "ash" "dash" "zsh"];
        });
      };
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        presets = genAttrs cfg.format.type (_: {enable = true;});
        setupOpts.formatters_by_ft.sh = cfg.format.type;
      };
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.diagnostics = {
        presets = genAttrs cfg.extraDiagnostics.types (_: {enable = true;});
        nvim-lint = {
          enable = true;
          linters_by_ft = {
            sh = cfg.extraDiagnostics.types;
            bash = cfg.extraDiagnostics.types;
            zsh = cfg.extraDiagnostics.types;
          };
        };
      };
    })
  ]);
}
