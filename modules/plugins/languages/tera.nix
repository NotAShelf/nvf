{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) genAttrs;
  inherit (lib.options) mkEnableOption literalExpression mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) enum listOf str;
  inherit (lib.nvim.types) mkGrammarOption;
  inherit (config.vim.lib) mkLanguageLspEnableOption;

  cfg = config.vim.languages.tera;

  defaultServers = [];
  servers = ["emmet-ls" "stimulus-language-server"];
in {
  options.vim.languages.tera = {
    enable = mkEnableOption "Tera templating language support";

    treesitter = {
      enable =
        mkEnableOption "Tera treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "tera";
      injection = mkOption {
        type = str;
        default = "html";
        description = "Treesitter language to inject in Tera templates";
      };
    };

    lsp = {
      enable = mkLanguageLspEnableOption {
        option = "tera";
        display = "Tera";
      };
      servers = mkOption {
        description = "Tera LSP server to use";
        type = listOf (enum servers);
        default = defaultServers;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter = {
        enable = true;
        grammars = [cfg.treesitter.package];
        queries = [
          {
            type = "injections";
            filetypes = ["tera"];
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
          filetypes = ["tera"];
        });
      };
    })
  ]);
}
