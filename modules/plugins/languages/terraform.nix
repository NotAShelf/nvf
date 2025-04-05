{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) isList attrNames;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) either package enum listOf str;
  inherit (lib.meta) getExe;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.languages) lspOptions;
  inherit (lib.nvim.types) mkGrammarOption;

  cfg = config.vim.languages.terraform;
  defaultServer = "terraform-ls";
  servers = {
    terraform-ls = {
      package = pkgs.terraform-ls;
      options = {
        cmd =
          if isList cfg.lsp.package
          then toLuaObject cfg.lsp.package
          else ''{"${getExe cfg.lsp.package}", "serve"}'';
      };
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
      enable = mkEnableOption "Terraform LSP support" // {default = config.vim.languages.enableLSP;};
      server = mkOption {
        type = listOf (enum (attrNames servers));
        default = defaultServer;
        description = "Terraform LSP server to use";
      };

      package = mkOption {
        type = either package (listOf str);
        default = servers.${cfg.lsp.server}.package;
        example = ''[lib.getExe pkgs.jdt-language-server "-data" "~/.cache/jdtls/workspace"]'';
        description = "Terraform LSP server package, or the command to run as a list of strings";
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
      vim.lsp.lspconfig.sources.terraform-ls = ''
        lspconfig.terraformls.setup {
          capabilities = capabilities,
          on_attach=default_on_attach,
          cmd = {"${cfg.lsp.package}/bin/terraform-ls", "serve"},
        }
      '';
    })
  ]);
}
