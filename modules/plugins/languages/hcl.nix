{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib) genAttrs;
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) enum listOf;
  inherit (lib.nvim.types) mkGrammarOption enumWithRename;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.hcl;

  defaultServers = ["tofu-ls"];
  servers = ["terraform-ls" "tofu-ls" "docker-language-server"];

  defaultFormat = ["hclfmt"];
  formats = {
    hclfmt = {
      command = getExe pkgs.hclfmt;
    };
    nomad-fmt = {
      command = getExe pkgs.nomad;
      args = ["fmt" "$FILENAME"];
      stdin = false;
    };
  };
in {
  options.vim.languages.hcl = {
    enable = mkEnableOption "HCL support";

    treesitter = {
      enable =
        mkEnableOption "HCL treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "hcl";
    };

    lsp = {
      enable =
        mkEnableOption "HCL LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };
      servers = mkOption {
        type = listOf (enumWithRename
          "vim.languages.hcl.lsp.servers"
          servers
          {
            terraformls-hcl = "terraform-ls";
            tofuls-hcl = "tofu-ls";
          });
        default = defaultServers;
        description = "HCL LSP server to use";
      };
    };

    format = {
      enable =
        mkEnableOption "HCL formatting"
        // {
          default = config.vim.languages.enableFormat;
          defaultText = literalExpression "config.vim.languages.enableFormat";
        };
      type = mkOption {
        type = listOf (enum (attrNames formats));
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

         ${
          if config.vim.comments.comment-nvim.enable
          then ''
            local ft = require('Comment.ft')
            ft.set('hcl', '#%s')
          ''
          else ""
        }
      '';
    }

    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp = {
        presets = genAttrs cfg.lsp.servers (_: {enable = true;});
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = ["hcl"];
        });
      };
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
