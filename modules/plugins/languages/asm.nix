{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) enum listOf;
  inherit (lib) genAttrs;
  inherit (lib.nvim.types) mkGrammarOption;

  cfg = config.vim.languages.assembly;
  defaultServers = ["asm-lsp"];
  servers = ["asm-lsp"];
in {
  options.vim.languages.assembly = {
    enable = mkEnableOption "Assembly support";

    treesitter = {
      enable =
        mkEnableOption "Assembly treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      packageASM = mkGrammarOption pkgs "asm";
      packageNASM = mkGrammarOption pkgs "nasm";
      packageRpiPicoASM = mkGrammarOption pkgs "pioasm";
    };

    lsp = {
      enable =
        mkEnableOption "Assembly LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };
      servers = mkOption {
        type = listOf (enum servers);
        default = defaultServers;
        description = "Assembly LSP server to use";
      };
    };
  };
  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [
        cfg.treesitter.packageASM
        cfg.treesitter.packageNASM
        cfg.treesitter.packageRpiPicoASM
      ];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp = {
        presets = genAttrs cfg.lsp.servers (_: {enable = true;});
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = ["asm" "nasm" "masm" "vmasm" "fasm" "tasm" "tiasm" "asm68k" "asmh8300"];
        });
      };
    })
  ]);
}
