{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) genAttrs;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.types) enum listOf str;
  inherit (lib.nvim.types) mkGrammarOption;

  cfg = config.vim.languages.arduino;

  defaultServers = ["arduino-language-server"];
  servers = ["arduino-language-server"];
in {
  options.vim.languages.arduino = {
    enable = mkEnableOption "Arduino support";

    treesitter = {
      enable =
        mkEnableOption "Arduino treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "arduino";
    };

    lsp = {
      enable =
        mkEnableOption "Arduino LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };
      servers = mkOption {
        type = listOf (enum servers);
        default = defaultServers;
        description = "Arduino LSP servers to use";
      };

      extraArgs = mkOption {
        type = listOf str;
        default = [];
        description = "Extra arguments passed to the Arduino LSP";
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
        presets = genAttrs cfg.lsp.servers (_: {enable = true;});
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = ["arduino"];
        });
      };
    })
  ]);
}
