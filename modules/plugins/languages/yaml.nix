{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.meta) getExe;
  inherit (lib.types) enum listOf;
  inherit (lib.nvim.types) mkGrammarOption mkServersOption;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.yaml;

  onAttach =
    if config.vim.languages.helm.lsp.enable
    then ''
      on_attach = function(client, bufnr)
        local filetype = vim.bo[bufnr].filetype
        if filetype == "helm" then
          client.stop()
        end
      end''
    else "on_attach = default_on_attach";

  defaultServers = ["yaml-language-server"];
  servers = {
    yaml-language-server = {
      enable = true;
      cmd = [(getExe pkgs.yaml-language-server) "--stdio"];
      filetypes = ["yaml" "yaml.docker-compose" "yaml.gitlab" "yaml.helm-values"];
      root_markers = [".git"];
      on_attach = onAttach;
      # -- https://github.com/redhat-developer/vscode-redhat-telemetry#how-to-disable-telemetry-reporting
      settings = {
        redhat = {
          telemetry = {
            enabled = false;
          };
        };
      };
    };
  };
in {
  options.vim.languages.yaml = {
    enable = mkEnableOption "YAML language support";

    treesitter = {
      enable = mkEnableOption "YAML treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "yaml";
    };

    lsp = {
      enable = mkEnableOption "Yaml LSP support" // {default = config.vim.lsp.enable;};
      servers = mkServersOption "Yaml" servers defaultServers;
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
