{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.meta) getExe;
  inherit (lib.lists) isList;
  inherit (lib.types) either enum listOf package str;
  inherit (lib.nvim.types) mkGrammarOption;
  inherit (lib.nvim.lua) expToLua;

  cfg = config.vim.languages.ocaml;

  defaultServer = "ocaml-lsp";
  servers = {
    ocaml-lsp = {
      package = pkgs.ocamlPackages.ocaml-lsp;
      lspConfig = ''
        lspconfig.ocamllsp.setup {
          capabilities = capabilities,
          on_attach = default_on_attach,
            cmd = ${
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else ''{"${getExe cfg.lsp.package}"}''
        };
        }
      '';
    };
  };

  defaultFormat = "ocamlformat";
  formats = {
    ocamlformat = {
      package = pkgs.ocamlPackages.ocamlformat;
    };
  };
in {
  options.vim.languages.ocaml = {
    enable = mkEnableOption "OCaml language support";

    treesitter = {
      enable = mkEnableOption "OCaml treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "ocaml";
    };

    lsp = {
      enable = mkEnableOption "OCaml LSP support (ocaml-lsp)" // {default = config.vim.lsp.enable;};
      server = mkOption {
        description = "OCaml LSP server to user";
        type = enum (attrNames servers);
        default = defaultServer;
      };
      package = mkOption {
        description = "OCaml language server package, or the command to run as a list of strings";
        type = either package (listOf str);
        default = servers.${cfg.lsp.server}.package;
      };
    };

    format = {
      enable = mkEnableOption "OCaml formatting support (ocamlformat)" // {default = config.vim.languages.enableFormat;};
      type = mkOption {
        description = "OCaml formatter to use";
        type = enum (attrNames formats);
        default = defaultFormat;
      };
      package = mkOption {
        description = "OCaml formatter package";
        type = package;
        default = formats.${cfg.format.type}.package;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.ocaml-lsp = servers.${cfg.lsp.server}.lspConfig;
    })

    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts.formatters_by_ft.ocaml = [cfg.format.type];
        setupOpts.formatters.${cfg.format.type} = {
          command = getExe cfg.format.package;
        };
      };
    })
  ]);
}
