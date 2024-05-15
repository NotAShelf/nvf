{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.meta) getExe;
  inherit (lib.lists) isList;
  inherit (lib.types) either listOf package str;
  inherit (lib.nvim.types) mkGrammarOption;
  inherit (lib.nvim.lua) expToLua;

  cfg = config.vim.languages.ocaml;
in {
  options.vim.languages.ocaml = {
    enable = mkEnableOption "OCaml language support";

    treesitter = {
      enable = mkEnableOption "OCaml treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "ocaml";
    };

    lsp = {
      enable = mkEnableOption "OCaml LSP support (ocaml-lsp)" // {default = config.vim.languages.enableLSP;};
      package = mkOption {
        description = "ocaml language server package, or the command to run as a list of strings";
        type = either package (listOf str);
        default = pkgs.ocamlPackages.ocaml-lsp;
      };
    };

    format = {
      enable = mkEnableOption "OCaml formatting support (ocamlformat)" // {default = config.vim.languages.enableFormat;};
      package = mkOption {
        description = "OCaml formatter package";
        type = package;
        default = pkgs.ocamlPackages.ocamlformat;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.ocaml-lsp = ''
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
    })

    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.format.enable {
      vim.lsp.null-ls.enable = true;
      vim.lsp.null-ls.sources.ocamlformat = ''
        table.insert(
          ls_sources,
          null_ls.builtins.formatting.ocamlformat.with({
            command = "${cfg.format.package}/bin/ocamlformat",
          })
        )
      '';
    })
  ]);
}
