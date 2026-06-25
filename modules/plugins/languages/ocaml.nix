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
  inherit (lib.nvim.types) mkGrammarOption deprecatedSingleOrListOf;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.ocaml;

  defaultServers = ["ocaml-lsp"];
  servers = ["ocaml-lsp"];

  defaultFormat = ["ocamlformat"];
  formats = {
    ocamlformat = {
      command = getExe pkgs.ocamlPackages.ocamlformat;
    };
  };
in {
  options.vim.languages.ocaml = {
    enable = mkEnableOption "OCaml language support";

    treesitter = {
      enable =
        mkEnableOption "OCaml treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "ocaml";
    };

    lsp = {
      enable =
        mkEnableOption "OCaml LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };

      servers = mkOption {
        type = listOf (enum servers);
        default = defaultServers;
        description = "OCaml LSP server to use";
      };
    };

    format = {
      enable = mkEnableOption "OCaml formatting support (ocamlformat)" // {default = config.vim.languages.enableFormat;};
      type = mkOption {
        type = deprecatedSingleOrListOf "vim.language.ocaml.format.type" (enum (attrNames formats));
        default = defaultFormat;
        description = "OCaml formatter to use";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.lsp.enable {
      vim.lsp = {
        presets = genAttrs cfg.lsp.servers (_: {enable = true;});
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = ["ocaml" "menhir" "ocamlinterface" "ocamllex" "reason" "dune"];
        });
      };
    })

    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts = {
          formatters_by_ft.ocaml = cfg.format.type;
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
