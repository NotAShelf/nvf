{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.lists) isList;
  inherit (lib.types) enum either listOf package str;
  inherit (lib.attrsets) attrNames;
  inherit (lib.nvim.lua) expToLua;
  inherit (lib.nvim.types) mkGrammarOption;

  cfg = config.vim.languages.typst;

  defaultFormat = "typstfmt";
  formats = {
    typstfmt = {
      package = pkgs.typstfmt;
      nullConfig = ''
        table.insert(
          ls_sources,
          null_ls.builtins.formatting.typstfmt.with({
            command = "${cfg.format.package}/bin/typstfmt",
          })
        )
      '';
    };
    # https://github.com/Enter-tainer/typstyle
    typstyle = {
      package = pkgs.typstyle;
      nullConfig = ''
        table.insert(
          ls_sources,
          null_ls.builtins.formatting.typstfmt.with({
            command = "${cfg.format.package}/bin/typstyle",
          })
        )
      '';
    };
  };
in {
  options.vim.languages.typst = {
    enable = mkEnableOption "Typst language support";

    treesitter = {
      enable = mkEnableOption "Typst treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "typst";
    };

    lsp = {
      enable = mkEnableOption "Typst LSP support (typst-lsp)" // {default = config.vim.languages.enableLSP;};

      package = mkOption {
        description = "typst-lsp package, or the command to run as a list of strings";
        example = ''[lib.getExe pkgs.jdt-language-server "-data" "~/.cache/jdtls/workspace"]'';
        type = either package (listOf str);
        default = pkgs.typst-lsp;
      };
    };

    format = {
      enable = mkEnableOption "Typst document formatting" // {default = config.vim.languages.enableFormat;};

      type = mkOption {
        description = "Typst formatter to use";
        type = enum (attrNames formats);
        default = defaultFormat;
      };

      package = mkOption {
        description = "Typst formatter package";
        type = package;
        default = formats.${cfg.format.type}.package;
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
      vim.lsp.lspconfig.sources.typst-lsp = ''
        lspconfig.typst_lsp.setup {
          capabilities = capabilities,
          on_attach=default_on_attach,
          cmd = ${
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else ''{"${cfg.lsp.package}/bin/typst-lsp"}''
        },
        }
      '';
    })
  ]);
}
