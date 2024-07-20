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
  inherit (lib.types) bool enum either listOf package str;
  inherit (lib.nvim.types) mkGrammarOption;
  inherit (lib.nvim.lua) expToLua;
  inherit (lib.nvim.dag) entryAfter;

  cfg = config.vim.languages.go;

  defaultServer = "gopls";
  servers = {
    gopls = {
      package = pkgs.gopls;
      lspConfig = ''
        lspconfig.gopls.setup {
          capabilities = capabilities;
          on_attach = default_on_attach;
          cmd = ${
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else ''{"${cfg.lsp.package}/bin/gopls", "serve"}''
        },
        }
      '';
    };
  };

  defaultDebugger = "delve";
  debuggers = {
    delve = {
      package = pkgs.delve;
    };
  };
in {
  options.vim.languages.go = {
    enable = mkEnableOption "Go language support";

    treesitter = {
      enable = mkEnableOption "Go treesitter" // {default = config.vim.languages.enableTreesitter;};

      package = mkGrammarOption pkgs "go";
    };

    lsp = {
      enable = mkEnableOption "Go LSP support" // {default = config.vim.languages.enableLSP;};

      server = mkOption {
        description = "Go LSP server to use";
        type = enum (attrNames servers);
        default = defaultServer;
      };

      package = mkOption {
        description = "Go LSP server package, or the command to run as a list of strings";
        example = ''[lib.getExe pkgs.jdt-language-server " - data " " ~/.cache/jdtls/workspace "]'';
        type = either package (listOf str);
        default = servers.${cfg.lsp.server}.package;
      };
    };

    dap = {
      enable = mkOption {
        description = "Enable Go Debug Adapter via nvim-dap-go plugin";
        type = bool;
        default = config.vim.languages.enableDAP;
      };

      debugger = mkOption {
        description = "Go debugger to use";
        type = enum (attrNames debuggers);
        default = defaultDebugger;
      };

      package = mkOption {
        description = "Go debugger package.";
        type = package;
        default = debuggers.${cfg.dap.debugger}.package;
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
      vim.lsp.lspconfig.sources.go-lsp = servers.${cfg.lsp.server}.lspConfig;
    })

    (mkIf cfg.dap.enable {
      vim = {
        startPlugins = ["nvim-dap-go"];
        pluginRC.nvim-dap-go = entryAfter ["nvim-dap"] ''
          require('dap-go').setup {
            delve = {
              path = '${getExe cfg.dap.package}',
            }
          }
        '';
        debugger.nvim-dap.enable = true;
      };
    })
  ]);
}
