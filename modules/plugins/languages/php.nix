{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.lists) isList;
  inherit (lib.types) enum either listOf package str;
  inherit (lib.nvim.types) mkGrammarOption;
  inherit (lib.nvim.lua) expToLua;

  cfg = config.vim.languages.php;

  defaultServer = "phpactor";
  servers = {
    phpactor = {
      package = pkgs.phpactor;
      lspConfig = ''
        lspconfig.phpactor.setup{
          capabilities = capabilities,
          on_attach = default_on_attach,
          cmd = ${
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else ''
            {
              "${getExe cfg.lsp.package}",
              "language-server"
            },
          ''
        }
        }
      '';
    };

    phan = {
      package = pkgs.php81Packages.phan;
      lspConfig = ''
        lspconfig.phan.setup{
          capabilities = capabilities,
          on_attach = default_on_attach,
          cmd = ${
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else ''
              {
                "${getExe cfg.lsp.package}",
                "-m",
                "json",
                "--no-color",
                "--no-progress-bar",
                "-x",
                "-u",
                "-S",
                "--language-server-on-stdin",
                "--allow-polyfill-parser"
            },
          ''
        }
        }
      '';
    };

    intelephense = {
      package = pkgs.intelephense;
      lspConfig = ''
        lspconfig.intelephense.setup{
          capabilities = capabilities,
          on_attach = default_on_attach,
          cmd = ${
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else ''
            {
              "${getExe cfg.lsp.package}",
              "--stdio"
            },
          ''
        }
        }
      '';
    };
  };
in {
  options.vim.languages.php = {
    enable = mkEnableOption "PHP language support";

    treesitter = {
      enable = mkEnableOption "PHP treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "php";
    };

    lsp = {
      enable = mkEnableOption "PHP LSP support" // {default = config.vim.languages.enableLSP;};

      server = mkOption {
        description = "PHP LSP server to use";
        type = enum (attrNames servers);
        default = defaultServer;
      };

      package = mkOption {
        description = "PHP LSP server package, or the command to run as a list of strings";
        example = ''[lib.getExe pkgs.jdt-language-server " - data " " ~/.cache/jdtls/workspace "]'';
        type = either package (listOf str);
        default = servers.${cfg.lsp.server}.package;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })
    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig = {
        enable = true;
        sources.php-lsp = servers.${cfg.lsp.server}.lspConfig;
      };
    })
  ]);
}
