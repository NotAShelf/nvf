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
  inherit (lib.types) bool enum listOf;
  inherit (lib.nvim.types) mkGrammarOption deprecatedSingleOrListOf;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.hcl;

  defaultServers = ["terraform-ls"];
  servers = {
    terraform-ls = {
      enable = true;
      cmd = [(getExe pkgs.terraform-ls) "serve"];
      filetypes = ["terraform" "terraform-vars"];
      root_markers = [".terraform" ".git"];
    };
  };

  defaultFormat = ["hclfmt"];
  formats = {
    hclfmt = {
      command = getExe pkgs.hclfmt;
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
      enable = mkEnableOption "HCL LSP support" // {default = config.vim.lsp.enable;};
      servers = mkOption {
        type = listOf (enum (attrNames servers));
        default = defaultServers;
        description = "HCL LSP server to use";
      };
    };

    format = {
      enable = mkOption {
        type = bool;
        default = config.vim.languages.enableFormat;
        description = "Enable HCL formatting";
      };
      type = mkOption {
        type = deprecatedSingleOrListOf "vim.language.hcl.format.type" (enum (attrNames formats));
        default = defaultFormat;
        description = "HCL formatter to use";
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
      vim.lsp.servers =
        mapListToAttrs (n: {
          name = n;
          value = servers.${n};
        })
        cfg.lsp.servers;
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts = {
          formatters_by_ft.hcl = cfg.format.type;
          formatters =
            mapListToAttrs (name: {
              inherit name;
              value = formats.${name};
            })
            cfg.format.type;
        };
      };
    })
  ]);
}
