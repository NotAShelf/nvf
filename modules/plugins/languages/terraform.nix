{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib) genAttrs;
  inherit (lib.types) listOf;
  inherit (lib.nvim.types) mkGrammarOption enumWithRename;

  cfg = config.vim.languages.terraform;

  defaultServers = ["tofu-ls"];
  servers = ["terraform-ls" "tofu-ls"];

  defaultFormat = ["opentofu"];
  formats = ["opentofu" "terraform"];
in {
  options.vim.languages.terraform = {
    enable = mkEnableOption "Terraform support";

    treesitter = {
      enable =
        mkEnableOption "Terraform treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "terraform";
    };

    lsp = {
      enable =
        mkEnableOption "Terraform LSP support (terraform-ls)"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };
      servers = mkOption {
        type = listOf (enumWithRename
          "vim.languages.terraform.lsp.servers"
          servers
          {
            terraformls-tf = "terraform-ls";
            tofuls-tf = "tofu-ls";
          });
        default = defaultServers;
        description = "Terraform LSP server to use";
      };
    };

    format = {
      enable =
        mkEnableOption "Enable Terraform formatting"
        // {
          default = config.vim.languages.enableFormat;
          defaultText = literalExpression "config.vim.languages.enableFormat";
        };
      type = mkOption {
        type = listOf (enumWithRename
          "vim.languages.hcl.format.type"
          formats
          {
            tofu-fmt = "opentofu";
            terraoform-fmt = "terraform";
          });
        default = defaultFormat;
        description = "Terraform formatter to use";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp = {
        presets = genAttrs cfg.lsp.servers (_: {enable = true;});
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = ["terraform" "terraform-vars" "tf"];
        });
      };
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        presets = genAttrs cfg.format.type (_: {enable = true;});
        setupOpts.formatters_by_ft.terraform = cfg.format.type;
      };
    })
  ]);
}
