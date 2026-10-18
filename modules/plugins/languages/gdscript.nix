{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib) genAttrs;
  inherit (lib.types) enum listOf;
  inherit (lib.nvim.types) mkGrammarOption;

  cfg = config.vim.languages.gdscript;

  defaultServers = ["gdscript"];
  servers = ["gdscript"];

  defaultFormat = ["gdscript-formatter"];
  formats = ["gdscript-formatter" "injected"];
in {
  options.vim.languages.gdscript = {
    enable = mkEnableOption "GDScript language support";

    treesitter = {
      enable =
        mkEnableOption "GDScript treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "gdscript";
      packageGodotResource = mkGrammarOption pkgs "godot_resource";
    };

    lsp = {
      enable =
        mkEnableOption "GDScript LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };

      servers = mkOption {
        type = listOf (enum servers);
        default = defaultServers;
        description = "GDScript LSP server to use";
      };
    };

    format = {
      enable =
        mkEnableOption "GDScript formatting"
        // {
          default = config.vim.languages.enableFormat;
          defaultText = literalExpression "config.vim.languages.enableFormat";
        };
      type = mkOption {
        type = listOf (enum formats);
        default = defaultFormat;
        description = "GDScript formatter to use";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter = {
        enable = true;
        grammars = [
          cfg.treesitter.package
          cfg.treesitter.packageGodotResource
        ];
      };
    })

    (mkIf cfg.lsp.enable {
      vim.lsp = {
        presets = genAttrs cfg.lsp.servers (_: {enable = true;});
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = ["gdscript"];
        });
      };
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        presets = genAttrs cfg.format.type (_: {enable = true;});
        setupOpts.formatters_by_ft.gdscript = cfg.format.type;
      };
    })
  ]);
}
