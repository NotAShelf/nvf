{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.lists) isList;
  inherit (lib.types) enum either listOf package str;
  inherit (lib.nvim.types) mkGrammarOption;
  inherit (lib.nvim.lua) expToLua;

  cfg = config.vim.languages.helm;
  yamlCfg = config.vim.languages.yaml;

  helmCmd =
    if isList cfg.lsp.package
    then cfg.lsp.package
    else ["${cfg.lsp.package}/bin/helm_ls" "serve"];
  yamlCmd =
    if isList yamlCfg.lsp.package
    then builtins.elemAt yamlCfg.lsp.package 0
    else "${yamlCfg.lsp.package}/bin/yaml-language-server";

  defaultServer = "helm-ls";
  servers = {
    helm-ls = {
      package = pkgs.helm-ls;
      lspConfig = ''
        lspconfig.helm_ls.setup {
          capabilities = capabilities,
          on_attach = default_on_attach,
          cmd = ${expToLua helmCmd},
          settings = {
            ['helm-ls'] = {
              yamlls = {
                  path = "${yamlCmd}"
              }
            }
          }
        }
      '';
    };
  };
in {
  options.vim.languages.helm = {
    enable = mkEnableOption "Helm language support";

    treesitter = {
      enable = mkEnableOption "Helm treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "helm";
    };

    lsp = {
      enable = mkEnableOption "Helm LSP support" // {default = config.vim.languages.enableLSP;};

      server = mkOption {
        description = "Helm LSP server to use";
        type = enum (attrNames servers);
        default = defaultServer;
      };

      package = mkOption {
        description = "Helm LSP server package";
        type = either package (listOf str);
        default = servers.${cfg.lsp.server}.package;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.helm-lsp = servers.${cfg.lsp.server}.lspConfig;
    })

    {
      # Enables filetype detection
      vim.startPlugins = [pkgs.vimPlugins.vim-helm];
    }
  ]);
}
