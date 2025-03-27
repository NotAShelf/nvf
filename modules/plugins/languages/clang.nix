{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) bool enum package either listOf str;
  inherit (lib.lists) isList;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.lua) expToLua toLuaObject;
  inherit (lib.nvim.types) mkGrammarOption;
  inherit (lib.nvim.languages) lspOptions;

  inherit (lib.nvim.dag) entryAfter;

  cfg = config.vim.languages.clang;

  packageToCmd = package: defaultCmd:
    if isList package
    then expToLua package
    else ''{ "${package}/bin/${defaultCmd}" }'';

  defaultServer = "clangd";
  servers = {
    ccls = {
      package = pkgs.ccls;
      options = {
        capabilities = mkLuaInline "capabilities";
        on_attach = mkLuaInline "default_on_attach";
        filetypes = ["c" "cpp" "objc" "objcpp" "cuda"];
        offset_encoding = "utf-32";
        cmd =
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else ["${packageToCmd cfg.lsp.package "ccls"}"];
        single_file_support = false; # upstream default
      };
    };

    clangd = {
      package = pkgs.clang-tools;
      options = {
        capabilities = mkLuaInline ''
          {
            offsetEncoding = { "utf-8", "utf-16" },
            textDocument = {
            completion = {
              editsNearCursor = true
            }
          }
        '';
        on_attach = mkLuaInline "default_on_attach";
        filetypes = ["c" "cpp" "objc" "objcpp" "cuda" "proto"];
        offset_encoding = "utf-32";
        cmd =
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else ["${packageToCmd cfg.lsp.package "clangd"}"];
        single_file_support = false; # upstream default
      };
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
      enable = mkEnableOption "C/C++ LSP support" // {default = config.vim.languages.enableLSP;};

      server = mkOption {
        description = "The C/C++ LSP server to use";
        type = enum (attrNames servers);
        default = defaultServer;
      };

      package = mkOption {
        description = "clang LSP server package, or the command to run as a list of strings";
        example = ''[lib.getExe pkgs.jdt-language-server " - data " " ~/.cache/jdtls/workspace "]'';
        type = either package (listOf str);
        default = servers.${cfg.lsp.server}.package;
      };

      options = mkOption {
        type = lspOptions;
        default = servers.${cfg.lsp.server}.options;
        description = ''
          LSP options for C/C++ language support.

          This option is freeform, you may add options that are not set by default
          and they will be merged into the final table passed to lspconfig.
        '';
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
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.clang-lsp = ''
        lspconfig.${toLuaObject cfg.lsp.server}.setup(${toLuaObject cfg.lsp.options})
      '';
    })

    (mkIf cfg.dap.enable {
      vim.debugger.nvim-dap.enable = true;
      vim.debugger.nvim-dap.sources.clang-debugger = debuggers.${cfg.dap.debugger}.dapConfig;
    })
  ]);
}
