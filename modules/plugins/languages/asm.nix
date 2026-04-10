{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) enum;
  inherit (lib.nvim.types) mkGrammarOption deprecatedSingleOrListOf;
  inherit (lib.meta) getExe;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.assembly;
  defaultServers = ["asm-lsp"];
  servers = {
    asm-lsp = {
      enable = true;
      cmd = [(getExe pkgs.asm-lsp)];
      filetypes = ["asm" "nasm" "masm" "vmasm" "fasm" "tasm" "tiasm" "asm68k" "asm8300"];
      root_markers = [".asm-lsp.toml" ".git"];
    };
  };
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
      packagePicoASM = mkGrammarOption pkgs "picoasm";
    };

    lsp = {
      enable =
        mkEnableOption "Assembly LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };
      servers = mkOption {
        type = deprecatedSingleOrListOf "vim.language.asm.lsp.servers" (enum (attrNames servers));
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
        cfg.treesitter.packagePicoASM
      ];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.servers =
        mapListToAttrs (n: {
          name = n;
          value = servers.${n};
        })
        cfg.lsp.servers;
    })
  ]);
}
