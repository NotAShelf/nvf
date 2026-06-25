{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkOption mkEnableOption literalExpression;
  inherit (lib.meta) getExe';
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) enum bool listOf;
  inherit (lib) genAttrs;
  inherit (lib.nvim.types) mkGrammarOption;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.fish;

  defaultServers = ["fish-lsp"];
  servers = ["fish-lsp"];

  defaultFormat = ["fish_indent"];
  formats = {
    fish_indent = {
      command = getExe' pkgs.fish "fish_indent";
    };
  };
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
        type = listOf (enum (attrNames formats));
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
        setupOpts = {
          formatters_by_ft.fish = cfg.format.type;
          formatters =
            mapListToAttrs (name: {
              inherit name;
              value = formats.${name};
            })
            cfg.format.type;
        };
      };
    })
  ]);
}
