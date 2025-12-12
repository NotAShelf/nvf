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
  inherit (lib.types) enum listOf;
  inherit (lib.nvim.types) mkGrammarOption;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.terraform;

  defaultServers = ["terraformls"];
  servers = {
    terraformls = {
      enable = true;
      cmd = [(getExe pkgs.terraform-ls) "serve"];
      filetypes = ["terraform" "terraform-vars"];
      root_markers = [".terraform" ".git"];
    };
  };
in {
  options.vim.languages.terraform = {
    enable = mkEnableOption "Terraform/HCL support";

    treesitter = {
      enable = mkEnableOption "Terraform treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "terraform";
    };

    lsp = {
      enable = mkEnableOption "Terraform LSP support (terraform-ls)" // {default = config.vim.lsp.enable;};

      servers = mkOption {
        type = listOf (enum (attrNames servers));
        default = defaultServers;
        description = "Terraform LSP server to use";
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
