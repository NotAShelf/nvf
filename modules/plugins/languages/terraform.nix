{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) package;
  inherit (lib.nvim.types) mkGrammarOption;

  cfg = config.vim.languages.terraform;
in {
  options.vim.languages.terraform = {
    enable = mkEnableOption "Terraform/HCL support";

    treesitter = {
      enable = mkEnableOption "Terraform treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "terraform";
    };

    lsp = {
      enable = mkEnableOption "Terraform LSP support (terraform-ls)" // {default = config.vim.lsp.enable;};

      package = mkOption {
        description = "terraform-ls package";
        type = package;
        default = pkgs.terraform-ls;
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
