{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption literalExpression;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) enum listOf;
  inherit (lib) genAttrs;
  inherit (lib.nvim.types) mkGrammarOption;
  inherit (config.vim.lib) mkLanguageLspEnableOption;

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
      enable = mkLanguageLspEnableOption {
        option = "vhdl";
        display = "VHDL";
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
