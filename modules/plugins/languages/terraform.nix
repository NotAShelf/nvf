{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib) genAttrs;
  inherit (lib.meta) getExe;
  inherit (lib.types) enum listOf;
  inherit (lib.nvim.types) mkGrammarOption enumWithRename;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.terraform;

  defaultServers = ["tofu-ls"];
  servers = ["terraform-ls" "tofu-ls"];

  defaultFormat = ["tofu-fmt"];
  formats = {
    tofu-fmt = {
      command = "${getExe pkgs.opentofu}";
      args = ["fmt" "$FILENAME"];
      stdin = false;
    };
    terraform-fmt = {
      command = "${getExe pkgs.terraform}";
      args = ["fmt" "$FILENAME"];
      stdin = false;
    };
  };
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
        type = listOf (enum (attrNames formats));
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
        setupOpts = {
          formatters_by_ft.terraform = cfg.format.type;
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
