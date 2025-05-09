{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) package bool enum;
  inherit (lib.nvim.types) mkGrammarOption;

  cfg = config.vim.languages.hcl;

  defaultServer = "terraform-ls";
  servers = {
    terraform-ls = {
      package = pkgs.terraform-ls;
      lspConfig = ''
        lspconfig.terraformls.setup {
          capabilities = capabilities,
          on_attach=default_on_attach,
          cmd = {"${lib.getExe cfg.lsp.package}", "serve"},
        }
      '';
    };
  };

  defaultFormat = "hclfmt";
  formats = {
    hclfmt = {
      package = pkgs.hclfmt;
    };
  };
in {
  options.vim.languages.hcl = {
    enable = mkEnableOption "HCL support";

    treesitter = {
      enable = mkEnableOption "HCL treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "hcl";
    };

    lsp = {
      enable = mkEnableOption "HCL LSP support (terraform-ls)" // {default = config.vim.lsp.enable;};
      # TODO: (maybe, is it better?) it would be cooler to use vscode-extensions.hashicorp.hcl probably, shouldn't be too hard
      package = mkOption {
        type = package;
        default = servers.${defaultServer}.package;
        description = "HCL language server package (terraform-ls)";
      };
    };

    format = {
      enable = mkOption {
        type = bool;
        default = config.vim.languages.enableFormat;
        description = "Enable HCL formatting";
      };
      type = mkOption {
        type = enum (attrNames formats);
        default = defaultFormat;
        description = "HCL formatter to use";
      };
      package = mkOption {
        type = package;
        default = formats.${cfg.format.type}.package;
        description = "HCL formatter package";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      # hcl style official: https://developer.hashicorp.com/terraform/language/style#code-formatting
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
        terraform-ls = servers.${cfg.lsp.server}.lspConfig;
      };
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts.formatters_by_ft.hcl = [cfg.format.type];
        setupOpts.formatters.${cfg.format.type} = {
          command = getExe cfg.format.package;
        };
      };
    })
  ]);
}
