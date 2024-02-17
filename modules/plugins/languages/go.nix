{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib) isList nvim getExe mkEnableOption mkOption types mkMerge mkIf;

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
          then nvim.lua.expToLua cfg.lsp.package
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
      dapConfig = ''
        dap.adapters.delve = {
          type = "server",
          port = "''${port}",
          executable = {
            command = "${getExe cfg.dap.package}",
            args = { "dap", "-l", "127.0.0.1:''${port}" },
          },
        }

        dap.configurations.go = {
          {
            type = "delve",
            name = "Debug",
            request = "launch",
            program = "''${file}",
          },
          {
            type = "delve",
            name = "Debug test", -- configuration for debugging test files
            request = "launch",
            mode = "test",
            program = "''${file}",
          },
          -- works with go.mod packages and sub packages
          {
            type = "delve",
            name = "Debug test (go.mod)",
            request = "launch",
            mode = "test",
            program = "./''${relativeFileDirname}",
          },
        }
      '';
    };
  };
in {
  options.vim.languages.go = {
    enable = mkEnableOption "Go language support";

    treesitter = {
      enable = mkEnableOption "Go treesitter" // {default = config.vim.languages.enableTreesitter;};

      package = nvim.types.mkGrammarOption pkgs "go";
    };

    lsp = {
      enable = mkEnableOption "Go LSP support" // {default = config.vim.languages.enableLSP;};

      server = mkOption {
        description = "Go LSP server to use";
        type = with types; enum (attrNames servers);
        default = defaultServer;
      };

      package = mkOption {
        description = "Go LSP server package, or the command to run as a list of strings";
        example = ''[lib.getExe pkgs.jdt-language-server " - data " " ~/.cache/jdtls/workspace "]'';
        type = with types; either package (listOf str);
        default = servers.${cfg.lsp.server}.package;
      };
    };

    dap = {
      enable = mkOption {
        description = "Enable Go Debug Adapter";
        type = types.bool;
        default = config.vim.languages.enableDAP;
      };
      debugger = mkOption {
        description = "Go debugger to use";
        type = with types; enum (attrNames debuggers);
        default = defaultDebugger;
      };
      package = mkOption {
        description = "Go debugger package.";
        type = types.package;
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
      vim.debugger.nvim-dap.enable = true;
      vim.debugger.nvim-dap.sources.go-debugger = debuggers.${cfg.dap.debugger}.dapConfig;
    })
  ]);
}
