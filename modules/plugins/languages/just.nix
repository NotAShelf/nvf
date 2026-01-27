{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.meta) getExe;
  inherit (lib.types) enum listOf;
  inherit (lib.nvim.attrsets) mapListToAttrs;
  inherit (lib.nvim.types) mkGrammarOption;

  cfg = config.vim.languages.just;

  defaultServers = ["just-lsp"];
  servers = {
    just-lsp = {
      enable = true;
      cmd = [(getExe pkgs.just-lsp)];
      filetypes = ["just"];
      root_markers = [".git" "justfile"];
    };
  };
in {
  options.vim.languages.just = {
    enable = mkEnableOption "Just support";

    treesitter = {
      enable =
        mkEnableOption "Just treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "just";
    };

    lsp = {
      enable =
        mkEnableOption "Just LSP support" // {default = config.vim.lsp.enable;};
      servers = mkOption {
        type = listOf (enum (attrNames servers));
        default = defaultServers;
        description = "Just LSP server to use";
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
      vim.lsp.servers =
        mapListToAttrs (n: {
          name = n;
          value = servers.${n};
        })
        cfg.lsp.servers;
    })
  ]);
}
