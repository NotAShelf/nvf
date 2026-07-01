{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib.options) literalExpression mkEnableOption mkOption;
  inherit (lib.types) listOf;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib) genAttrs;
  inherit (lib.nvim.types) mkGrammarOption enumWithRename;

  cfg = config.vim.languages.julia;

  defaultServers = ["julia-languageserver"];
  servers = ["julia-languageserver"];
in {
  options = {
    vim.languages.julia = {
      enable = mkEnableOption "Julia language support";

      treesitter = {
        enable =
          mkEnableOption "Julia treesitter"
          // {
            default = config.vim.languages.enableTreesitter;
            defaultText = literalExpression "config.vim.languages.enableTreesitter";
          };
        package = mkGrammarOption pkgs "julia";
      };

      lsp = {
        enable =
          mkEnableOption "Julia LSP support"
          // {
            default = config.vim.lsp.enable;
            defaultText = literalExpression "config.vim.lsp.enable";
          };
        servers = mkOption {
          type = listOf (enumWithRename
            "vim.languages.julia.lsp.servers"
            servers
            {
              julials = "julia-languageserver";
            });
          default = defaultServers;
          description = ''
            Julia LSP Server to Use

            ::: {.note}
            The entirety of Julia is bundled with nvf, if you enable this
            option, since there is no way to provide only the LSP server.

            Since the LSP server is a julia package that needs to be bundled
            within a Julia binary, there is no way for us to provide only the
            LSP server. By default, you'll just have to add the `LanguageServer`
            package to Julia in your devshells (or general environment), and be
            good to go.

            If you want to have the entirety of Julia bundled within nvf, you can
            change {option}`vim.lsp.servers.presets.julia-languageserver.usePathBin`
            to `false` to have nvf bundle julia and the lsp.
            :::
          '';
        };
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
        lsp = {
          presets = genAttrs cfg.lsp.servers (_: {enable = true;});
          servers = genAttrs cfg.lsp.servers (_: {
            filetypes = ["julia"];
          });
        };
      };
    })
  ]);
}
