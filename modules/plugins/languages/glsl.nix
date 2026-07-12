{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.types) mkGrammarOption;
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.types) enum listOf;
  inherit (lib) genAttrs;
  inherit (config.vim.lib) mkLanguageLspEnableOption;

  cfg = config.vim.languages.glsl;

  defaultServers = ["glsl_analyzer"];
  servers = ["glsl_analyzer"];
in {
  options.vim.languages.glsl = {
    enable = mkEnableOption "GLSL language support";

    treesitter = {
      enable =
        mkEnableOption "GLSL treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "glsl";
    };

    lsp = {
      enable = mkLanguageLspEnableOption {
        option = "glsl";
        display = "GLSL";
      };

      servers = mkOption {
        type = listOf (enum servers);
        default = defaultServers;
        description = "GLSL LSP server to use";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      vim.filetype.extension = {
        vert = "glsl";
        tesc = "glsl";
        tese = "glsl";
        frag = "glsl";
        geom = "glsl";
        comp = "glsl";
      };
    }

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
          filetypes = ["glsl"];
        });
      };
    })
  ]);
}
