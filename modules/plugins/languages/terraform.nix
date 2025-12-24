{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames concatStringsSep elem;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.meta) getExe;
  inherit (lib.types) bool enum listOf;
  inherit (lib.nvim.types) mkGrammarOption deprecatedSingleOrListOf;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.terraform;

  defaultServers = ["tofuls"];
  servers = {
    terraformls = {
      enable = true;
      cmd = [(getExe pkgs.terraform-ls) "serve"];
      filetypes = ["terraform" "terraform-vars" "tf"];
      root_markers = [".terraform" ".git"];
    };
    tofuls = {
      enable = true;
      cmd = [(getExe pkgs.tofu-ls) "serve"];
      filetypes = ["terraform" "terraform-vars" "tf"];
      root_markers = [".terraform" ".git"];
    };
  };

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
        mkEnableOption "Terraform treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "terraform";
    };

    lsp = {
      enable =
        mkEnableOption "Terraform LSP support (terraform-ls)" // {default = config.vim.lsp.enable;};

      servers = mkOption {
        type = listOf (enum (attrNames servers));
        default = defaultServers;
        description = "Terraform LSP server to use (one or more of [${concatStringsSep " " (attrNames servers)}])";
      };
    };

    format = {
      enable = mkOption {
        type = bool;
        default = config.vim.languages.enableFormat;
        description = "Enable Terraform formatting";
      };
      type = mkOption {
        type = deprecatedSingleOrListOf "vim.language.terraform.format.type" (enum (attrNames formats));
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
      vim = {
        lsp.servers =
          mapListToAttrs (n: {
            name = n;
            value = servers.${n};
          })
          cfg.lsp.servers;
        extraPackages =
          (lib.optionals (elem "terraformls" cfg.lsp.servers) [pkgs.terraform])
          ++ (lib.optionals (elem "tofuls" cfg.lsp.servers) [pkgs.opentofu]);
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
