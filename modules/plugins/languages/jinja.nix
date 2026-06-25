{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) genAttrs;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) literalExpression mkEnableOption mkOption;
  inherit (lib.types) enum listOf str;
  inherit (lib.nvim.types) mkGrammarOption;

  cfg = config.vim.languages.jinja;

  defaultServers = ["jinja-lsp"];
  servers = ["jinja-lsp" "emmet-ls" "stimulus-language-server"];
in {
  options.vim.languages.jinja = {
    enable = mkEnableOption "Jinja template language support";

    treesitter = {
      enable =
        mkEnableOption "Jinja treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "jinja";
      inlinePackage = mkGrammarOption pkgs "jinja_inline";
      injection = mkOption {
        type = str;
        default = "html";
        description = "Treesitter language to inject in Jinja templates";
      };
    };

    lsp = {
      enable =
        mkEnableOption "Jinja LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };
      servers = mkOption {
        description = "Jinja LSP server to use";
        type = listOf (enum servers);
        default = defaultServers;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter = {
        enable = true;
        grammars = [
          cfg.treesitter.package
          cfg.treesitter.inlinePackage
        ];
        queries = [
          {
            type = "injections";
            filetypes = ["jinja"];
            query = ''
              ;; extends

              ((content) @injection.content
                (#set! injection.language "${cfg.treesitter.injection}")
                (#set! injection.combined)
              )
            '';
          }
        ];
      };
    })

    (mkIf cfg.lsp.enable {
      vim.lsp = {
        presets = genAttrs cfg.lsp.servers (_: {enable = true;});
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = ["jinja"];
        });
      };
    })
  ]);
}
