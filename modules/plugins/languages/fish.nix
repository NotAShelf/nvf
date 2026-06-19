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
  inherit (lib.nvim.types) mkGrammarOption enumWithRename;

  cfg = config.vim.languages.fish;

  defaultServers = ["fish-lsp"];
  servers = ["fish-lsp"];

  defaultFormat = ["fish-indent"];
  formats = ["fish-indent"];
in {
  options.vim.languages.fish = {
    enable = mkEnableOption "Fish language support";

    treesitter = {
      enable =
        mkEnableOption "Fish treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "fish";
    };

    lsp = {
      enable =
        mkEnableOption "Fish LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };
      servers = mkOption {
        type = listOf (enum servers);
        default = defaultServers;
        description = "Fish LSP server to use";
      };
    };

    format = {
      enable = mkOption {
        type = bool;
        default = config.vim.languages.enableFormat;
        defaultText = literalExpression "config.vim.languages.enableFormat";
        description = "Enable Fish formatting";
      };
      type = mkOption {
        type = listOf (enumWithRename
          "vim.languages.fish.format.type"
          formats
          {
            fish_indent = "fish-indent";
          });
        default = defaultFormat;
        description = "Fish formatter to use";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter = {
        enable = true;
        grammars = [cfg.treesitter.package];
      };
    })

    (mkIf cfg.lsp.enable {
      vim.lsp = {
        presets = genAttrs cfg.lsp.servers (_: {enable = true;});
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = ["fish"];
        });
      };
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        presets = genAttrs cfg.format.type (_: {enable = true;});
        setupOpts.formatters_by_ft.fish = cfg.format.type;
      };
    })
  ]);
}
