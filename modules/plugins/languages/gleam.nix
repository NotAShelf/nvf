{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.meta) getExe;
  inherit (lib.types) enum;
  inherit (lib.nvim.types) mkGrammarOption singleOrListOf;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.gleam;

  defaultServers = ["gleam"];
  servers = {
    gleam = {
      enable = true;
      cmd = [(getExe pkgs.gleam) "lsp"];
      filetypes = ["gleam"];
      root_markers = ["gleam.toml" ".git"];
    };
  };
in {
  options.vim.languages.gleam = {
    enable = mkEnableOption "Gleam language support";

    treesitter = {
      enable = mkEnableOption "Gleam treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "gleam";
    };

    lsp = {
      enable = mkEnableOption "Gleam LSP support" // {default = config.vim.lsp.enable;};
      servers = mkOption {
        type = singleOrListOf (enum (attrNames servers));
        default = defaultServers;
        description = "Gleam LSP server to use";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
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
