{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkOption mkEnableOption literalExpression;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) enum bool listOf;
  inherit (lib) genAttrs;
  inherit (lib.nvim.types) mkGrammarOption;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.vhdl;

  defaultServers = ["vhdl-ls"];
  servers = ["vhdl-ls"];
in {
  options.vim.languages.vhdl = {
    enable = mkEnableOption "VHDL language support";

    treesitter = {
      enable =
        mkEnableOption "VHDL treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "vhdl";
    };

    lsp = {
      enable =
        mkEnableOption "VHDL LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };
      servers = mkOption {
        type = listOf (enum servers);
        default = defaultServers;
        description = "VHDL LSP server to use";
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
          filetypes = ["vhdl"];
        });
      };
    })
  ]);
}
