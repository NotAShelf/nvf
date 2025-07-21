{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.strings) optionalString;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) bool enum package str nullOr;
  inherit (lib.meta) getExe getExe';
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.attrsets) mapListToAttrs;
  inherit (lib.nvim.types) mkGrammarOption mkServersOption;
  inherit (lib.nvim.dag) entryAfter;

  cfg = config.vim.languages.clang;

  defaultServers = ["clangd"];
  servers = {
    ccls = {
      enable = true;
      cmd = [(getExe pkgs.ccls)];
      filetypes = ["c" "cpp"];
      root_markers = [".clangd" "compile_commands.json" ".git"];
      init_options = optionalString (cfg.lsp.opts != null) cfg.lsp.opts;
    };

    clangd = {
      enable = true;
      cmd = [(getExe' pkgs.clang-tools "clangd")];
      filetypes = ["c" "cpp"];
      root_markers = [".clangd" "compile_commands.json" ".git"];
      capabilities = {
        offsetEncoding = ["utf-16"];
      };
      init_options = optionalString (cfg.lsp.opts != null) cfg.lsp.opts;
    };
  };

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
        dap.configurations.cpp = {
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

        dap.configurations.c = dap.configurations.cpp
      '';
    };
  };
in {
  options.vim.languages.clang = {
    enable = mkEnableOption "C/C++ language support";

    cHeader = mkOption {
      description = ''
        C syntax for headers. Can fix treesitter errors, see:
        https://www.reddit.com/r/neovim/comments/orfpcd/question_does_the_c_parser_from_nvimtreesitter/
      '';
      type = bool;
      default = false;
    };

    treesitter = {
      enable = mkEnableOption "C/C++ treesitter" // {default = config.vim.languages.enableTreesitter;};
      cPackage = mkGrammarOption pkgs "c";
      cppPackage = mkGrammarOption pkgs "cpp";
    };

    lsp = {
      enable = mkEnableOption "clang LSP support" // {default = config.vim.lsp.enable;};
      servers = mkServersOption "clang" servers defaultServers;

      opts = mkOption {
        description = "Options to pass to clang LSP server";
        type = nullOr str;
        default = null;
      };
    };

    dap = {
      enable = mkOption {
        description = "Enable clang Debug Adapter";
        type = bool;
        default = config.vim.languages.enableDAP;
      };
      debugger = mkOption {
        description = "clang debugger to use";
        type = enum (attrNames debuggers);
        default = defaultDebugger;
      };
      package = mkOption {
        description = "clang debugger package.";
        type = package;
        default = debuggers.${cfg.dap.debugger}.package;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.cHeader {
      vim.pluginRC.c-header = entryAfter ["basic"] "vim.g.c_syntax_for_h = 1";
    })

    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.cPackage cfg.treesitter.cppPackage];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.servers =
        mapListToAttrs (n: {
          name = n;
          value = servers.${n};
        })
        cfg.lsp.servers;
    })

    (mkIf cfg.dap.enable {
      vim.debugger.nvim-dap.enable = true;
      vim.debugger.nvim-dap.sources.clang-debugger = debuggers.${cfg.dap.debugger}.dapConfig;
    })
  ]);
}
