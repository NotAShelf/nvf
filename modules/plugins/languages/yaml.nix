{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (builtins) isList attrNames;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) enum either listOf package str;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.languages) lspOptions;
  inherit (lib.nvim.types) mkGrammarOption;
  inherit (lib.nvim.lua) expToLua;

  cfg = config.vim.languages.yaml;

  yamlOnAttach =
    if config.vim.languages.helm.lsp.enable
    then ''
      function(client, bufnr)
        local filetype = vim.bo[bufnr].filetype
        if filetype == "helm" then
          client.stop()
        end
      end''
    else "default_on_attach";

  defaultServer = "yaml-language-server";
  servers = {
    yaml-language-server = {
      package = pkgs.nodePackages.yaml-language-server;
      options = {
        on_attach = mkLuaInline yamlOnAttach;
        cmd =
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else ''{"${cfg.lsp.package}/bin/yaml-language-server", "--stdio"}'';
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
      enable = mkEnableOption "YAML LSP support" // {default = config.vim.languages.enableLSP;};

      server = mkOption {
        type = listOf (enum (attrNames servers));
        default = defaultServer;
        description = "YAML LSP server to use";
      };

      package = mkOption {
        type = either package (listOf str);
        default = servers.${cfg.lsp.server}.package;
        description = "YAML LSP server package";
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
      vim.lsp.lspconfig.sources.yaml-lsp = servers.${cfg.lsp.server}.lspConfig;
    })
  ]);
}
