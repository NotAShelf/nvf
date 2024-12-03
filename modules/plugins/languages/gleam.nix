{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.lists) isList;
  inherit (lib.types) enum either listOf package str;
  inherit (lib.nvim.lua) expToLua;

  cfg = config.vim.languages.gleam;

  defaultServer = "gleam";
  servers = {
    gleam = {
      package = pkgs.gleam;
      lspConfig = ''
        lspconfig.basedpyright.setup{
          capabilities = capabilities,
          on_attach = default_on_attach,
          cmd = ${
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else ''{"${cfg.lsp.package}/bin/gleam", "lsp"}''
        }
        }
      '';
    };
  };

  defaultFormat = "gleam_format";
  formats = {
    gleam_format = {
      package = pkgs.gleam;
      nullConfig = ''
        table.insert(
          ls_sources,
          null_ls.builtins.formatting.gleam_format.with({
            command = "${cfg.format.package}/bin/gleam",
          })
        )
      '';
    };
  };

in {
  options.vim.languages.gleam = {
    enable = mkEnableOption "Gleam language support";

    treesitter = {
      enable = mkEnableOption "Gleam treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkOption {
        type = package;
        default = pkgs.vimPlugins.nvim-treesitter.builtGrammars.gleam;
        description = "Gleam treesitter grammar to use";
      };
    };

    lsp = {
      enable = mkEnableOption "Gleam LSP support" // {default = config.vim.languages.enableLSP;};

      server = mkOption {
        type = enum (attrNames servers);
        default = defaultServer;
        description = "Gleam LSP server to use";
      };

      package = mkOption {
        type = either package (listOf str);
        default = servers.${cfg.lsp.server}.package;
        description = "gleam LSP server package, or the command to run as a list of strings";
      };
    };

    format = {
      enable = mkEnableOption "Gleam formatting" // {default = config.vim.languages.enableFormat;};

      type = mkOption {
        type = enum (attrNames formats);
        default = defaultFormat;
        description = "Gleam formatter to use";
      };

      package = mkOption {
        type = package;
        default = formats.${cfg.format.type}.package;
        description = "Gleam formatter package";
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
      vim.lsp.lspconfig.sources.gleam-lsp = servers.${cfg.lsp.server}.lspConfig;
    })

    (mkIf cfg.format.enable {
      vim.lsp.null-ls.enable = true;
      vim.lsp.null-ls.sources.gleam-format = formats.${cfg.format.type}.nullConfig;
    })
  ]);
}
