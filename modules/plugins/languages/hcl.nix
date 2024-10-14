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

  cfg = config.vim.languages.hcl;
in {
  options.vim.languages.hcl = {
    enable = mkEnableOption "HCL support";

    treesitter = {
      enable = mkEnableOption "HCL treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "hcl";
    };

    lsp = {
      enable = mkEnableOption "HCL LSP support (terraform-ls)" // {default = config.vim.languages.enableLSP;};
      # TODO: it would be cooler to use vscode-extensions.hashicorp.hcl probably, shouldn't be too hard
      # TODO: formatter, suppied by above or ...
      # FIXME: or should we somehow integrate this:
      #` https://git.mzte.de/nvim-plugins/null-ls.nvim/commit/e1fb7e2b2e4400835e23b9603a19813be119852b ??
      package = mkOption {
        description = "HCL ls package (terraform-ls)";
        type = package;
        default = pkgs.terraform-ls;
      };
    };
  };
  config = mkIf cfg.enable (mkMerge [
    {
      vim.pluginRC.hcl = ''
        vim.api.nvim_create_autocmd("FileType", {
          pattern = "hcl",
          callback = function(opts)
            local bo = vim.bo[opts.buf]
            bo.tabstop = 2
            bo.shiftwidth = 2
            bo.softtabstop = 2
          end
        })

        local ft = require('Comment.ft')
        ft
          .set('hcl', '#%s')
      '';
    }
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources = lib.optionalAttrs (! config.vim.languages.terraform.lsp.enable) {
        terraform-ls = ''
          lspconfig.terraformls.setup {
            capabilities = capabilities,
            on_attach=default_on_attach,
            cmd = {"${cfg.lsp.package}/bin/terraform-ls", "serve"},
          }
        '';
      };
    })
  ]);
}
