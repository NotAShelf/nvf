{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib) genAttrs;
  inherit (lib.types) enum listOf;
  inherit (lib.nvim.types) mkGrammarOption;

  cfg = config.vim.languages.yaml;

  defaultServers = ["yaml-language-server"];
  servers = ["yaml-language-server" "gitlab-ci-ls"];

  defaultFormat = ["prettier"];
  formats = ["prettier" "deno"];
in {
  options.vim.languages.yaml = {
    enable = mkEnableOption "YAML language support";

    treesitter = {
      enable =
        mkEnableOption "YAML treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };

      package = mkGrammarOption pkgs "yaml";
    };

    lsp = {
      enable =
        mkEnableOption "Yaml LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };
      servers = mkOption {
        type = listOf (enum servers);
        default = defaultServers;
        description = "Yaml LSP server to use";
      };
    };

    format = {
      enable =
        mkEnableOption "YAML formatting"
        // {
          default = config.vim.languages.enableFormat;
          defaultText = literalExpression "config.vim.languages.enableFormat";
        };

      type = mkOption {
        type = listOf (enum formats);
        default = defaultFormat;
        description = "YAML formatter to use";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      # The GitLab CI LSP ignores all filetypes which aren't `yaml.gitlab`.
      vim.filetype.pattern = {
        "%.gitlab%-ci%.ya?ml" = "yaml.gitlab";
        "%.gitlab/.*%.ya?ml" = "yaml.gitlab";
        "templates/.*%.ya?ml" = "yaml.gitlab";
        "templates/.*/template%.ya?ml" = "yaml.gitlab";
      };
    }

    (mkIf cfg.treesitter.enable {
      vim.treesitter = {
        enable = true;
        grammars = [cfg.treesitter.package];
        filetypeMappings.yaml = ["yml" "yaml.gitlab"];
      };
    })

    (mkIf cfg.lsp.enable {
      vim.lsp = {
        presets = genAttrs cfg.lsp.servers (_: {enable = true;});
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = ["yaml" "yaml.gitlab"];
        });
      };
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        presets = genAttrs cfg.format.type (_: {enable = true;});
        setupOpts.formatters_by_ft.yaml = cfg.format.type;
      };
    })
  ]);
}
