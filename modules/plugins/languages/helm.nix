{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (builtins) attrNames head;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkDefault mkIf mkMerge;
  inherit (lib.meta) getExe;
  inherit (lib.types) enum;
  inherit (lib.nvim.types) mkGrammarOption singleOrListOf;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.helm;
  yamlCfg = config.vim.languages.yaml;

  defaultServers = ["helm-ls"];
  servers = {
    helm-ls = {
      enable = true;
      cmd = [(getExe pkgs.helm-ls) "serve"];
      filetypes = ["helm" "yaml.helm-values"];
      root_markers = ["Chart.yaml"];
      capabilities = {
        didChangeWatchedFiles = {
          dynamicRegistration = true;
        };
      };
      settings = mkIf (yamlCfg.enable && yamlCfg.lsp.enable) {
        helm-ls = {
          yamlls = {
            # Without this being enabled, the YAML language module will look broken in helmfiles
            # if both modules are enabled at once.
            enabled = mkDefault yamlCfg.lsp.enable;
            path = head config.vim.lsp.servers.${head yamlCfg.lsp.servers}.cmd;
          };
        };
      };
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
      enable = mkEnableOption "Helm LSP support" // {default = config.vim.lsp.enable;};
      servers = mkOption {
        type = singleOrListOf (enum (attrNames servers));
        default = defaultServers;
        description = "Helm LSP server to use";
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

    {
      # Enables filetype detection
      vim.startPlugins = [pkgs.vimPlugins.vim-helm];
    }
  ]);
}
