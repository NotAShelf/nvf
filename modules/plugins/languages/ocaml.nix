{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) isList attrNames;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) either enum listOf package str;
  inherit (lib.meta) getExe;
  inherit (lib.nvim.languages) lspOptions;
  inherit (lib.nvim.types) mkGrammarOption;
  inherit (lib.nvim.lua) expToLua;

  cfg = config.vim.languages.ocaml;

  defaultServer = "ocaml-lsp";
  servers = {
    ocaml-lsp = {
      package = pkgs.ocamlPackages.ocaml-lsp;
      options = {
        cmd =
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else ''{"${getExe cfg.lsp.package}"}'';
      };
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
      enable = mkEnableOption "OCaml LSP support" // {default = config.vim.languages.enableLSP;};
      server = mkOption {
        type = listOf (enum (attrNames servers));
        default = defaultServer;
        description = "OCaml LSP server to user";
      };

      package = mkOption {
        type = either package (listOf str);
        default = servers.${cfg.lsp.server}.package;
        description = "OCaml language server package, or the command to run as a list of strings";
      };
    };

    format = {
      enable = mkEnableOption "OCaml formatting support" // {default = config.vim.languages.enableFormat;};
      type = mkOption {
        type = enum (attrNames formats);
        default = defaultFormat;
        description = "OCaml formatter to use";
      };
      package = mkOption {
        type = package;
        default = formats.${cfg.format.type}.package;
        description = "OCaml formatter package";
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
