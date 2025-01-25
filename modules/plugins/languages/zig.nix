{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge mkDefault;
  inherit (lib.lists) isList;
  inherit (lib.types) bool either listOf package str enum;
  inherit (lib.nvim.lua) expToLua;
  inherit (lib.nvim.types) mkGrammarOption;

  cfg = config.vim.languages.zig;

  defaultServer = "zls";
  servers = {
    zls = {
      package = pkgs.zls;
      internalFormatter = true;
      lspConfig = ''
        lspconfig.zls.setup {
          capabilities = capabilities,
          on_attach = default_on_attach,
          cmd = ${
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else "{'${cfg.lsp.package}/bin/zls'}"
        }
        }
      '';
    };
  };

  # TODO: dap.adapter.lldb is duplicated when enabling the
  # vim.languages.clang.dap module. This does not cause
  # breakage... but could be cleaner.
  defaultDebugger = "lldb-vscode";
  debuggers = {
    lldb-vscode = {
      package = pkgs.lldb;
      dapConfig = ''
        dap.adapters.lldb = {
          type = 'executable',
          command = '${cfg.dap.package}/bin/lldb-dap',
          name = 'lldb'
        }
        dap.configurations.zig = {
          {
            name = 'Launch',
            type = 'lldb',
            request = 'launch',
            program = function()
              return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
            end,
            cwd = "''${workspaceFolder}",
            stopOnEntry = false,
            args = {},
          },
        }
      '';
    };
  };
in {
  options.vim.languages.zig = {
    enable = mkEnableOption "Zig language support";

    treesitter = {
      enable = mkEnableOption "Zig treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "zig";
    };

    lsp = {
      enable = mkEnableOption "Zig LSP support" // {default = config.vim.languages.enableLSP;};

      server = mkOption {
        type = enum (attrNames servers);
        default = defaultServer;
        description = "Zig LSP server to use";
      };

      package = mkOption {
        description = "ZLS package, or the command to run as a list of strings";
        type = either package (listOf str);
        default = pkgs.zls;
      };
    };

    dap = {
      enable = mkOption {
        type = bool;
        default = config.vim.languages.enableDAP;
        description = "Enable Zig Debug Adapter";
      };

      debugger = mkOption {
        type = enum (attrNames debuggers);
        default = defaultDebugger;
        description = "Zig debugger to use";
      };

      package = mkOption {
        type = package;
        default = debuggers.${cfg.dap.debugger}.package;
        description = "Zig debugger package.";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter = {
        enable = true;
        grammars = [cfg.treesitter.package];
      };
    })

    (mkIf cfg.lsp.enable {
      vim = {
        lsp.lspconfig = {
          enable = true;
          sources.zig-lsp = servers.${cfg.lsp.server}.lspConfig;
        };

        # nvf handles autosaving already
        globals.zig_fmt_autosave = mkDefault 0;
      };
    })

    (mkIf cfg.dap.enable {
      vim = {
        debugger.nvim-dap.enable = true;
        debugger.nvim-dap.sources.zig-debugger = debuggers.${cfg.dap.debugger}.dapConfig;
      };
    })
  ]);
}
