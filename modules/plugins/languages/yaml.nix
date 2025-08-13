{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.meta) getExe;
  inherit (lib.types) enum;
  inherit (lib.nvim.types) mkGrammarOption singleOrListOf;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.yaml;

  on_attach = mkLuaInline (
    if config.vim.languages.helm.lsp.enable && config.vim.languages.helm.enable
    then ''
      function(client, bufnr)
        local filetype = vim.bo[bufnr].filetype
        if filetype == "helm" then
          client.stop()
        end
      end''
    else "default_on_attach"
  );

  defaultServers = ["yaml-language-server"];
  servers = {
    yaml-language-server = {
      enable = true;
      cmd = [(getExe pkgs.yaml-language-server) "--stdio"];
      filetypes = ["yaml" "yaml.docker-compose" "yaml.gitlab" "yaml.helm-values"];
      root_markers = [".git"];
      inherit on_attach;
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
      servers = mkOption {
        type = singleOrListOf (enum (attrNames servers));
        default = defaultServers;
        description = "Yaml LSP server to use";
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
