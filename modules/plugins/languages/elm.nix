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

  cfg = config.vim.languages.elm;

  defaultServers = ["elm-language-server"];
  servers = {
    elm-language-server = {
      enable = true;
      cmd = [(getExe pkgs.elmPackages.elm-language-server)];
      filetypes = ["elm"];
      root_markers = ["elm.json"];
      workspace_required = false;
    };
  };
in {
  options.vim.languages.elm = {
    enable = mkEnableOption "Elm language support";

    treesitter = {
      enable =
        mkEnableOption "Elm treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "elm";
    };

    lsp = {
      enable =
        mkEnableOption "Elm LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };

      servers = mkOption {
        type = deprecatedSingleOrListOf "vim.language.elm.lsp.servers" (enum (attrNames servers));
        default = defaultServers;
        description = "Elm LSP servers to use";
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
      vim = {
        lsp.servers =
          mapListToAttrs (n: {
            name = n;
            value = servers.${n};
          })
          cfg.lsp.servers;
      };
    })
  ]);
}
