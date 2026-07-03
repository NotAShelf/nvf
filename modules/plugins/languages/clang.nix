{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.types) bool enum listOf;
  inherit (lib) genAttrs;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.types) mkGrammarOption;
  inherit (lib.nvim.dag) entryAfter;
  inherit (lib.nvim.types) deprecatedSingleOrListOf enumWithRename;

  cfg = config.vim.languages.clang;

  defaultServers = ["clangd"];
  servers = ["ccls" "clangd"];

  defaultDebugger = ["lldb"];
  dapConfigurations = {
    lldb = [
      {
        name = "Launch";
        type = "lldb";
        request = "launch";
        program = mkLuaInline ''
          function()
            return nvf_dap_cached_input(
              'clang_lldb_launch_exe',
              "Path to executable: ",
              vim.fn.getcwd() .. "/",
              "file")
          end
        '';
        cwd = "\${workspaceFolder}";
        stopOnEntry = false;
        args = [];
      }
    ];
  };

  defaultFormat = ["clang-format"];
  formats = ["clang-format" "indent" "astyle"];

  defaultDiagnosticsProvider = ["cpplint"];
  diagnosticsProviders = ["cpplint"];
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
      enable =
        mkEnableOption "C/C++ treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      cPackage = mkGrammarOption pkgs "c";
      cppPackage = mkGrammarOption pkgs "cpp";
    };

    lsp = {
      enable =
        mkEnableOption "clang LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };

      servers = mkOption {
        description = "The clang LSP server to use";
        type = listOf (enum servers);
        default = defaultServers;
      };
    };

    dap = {
      enable = mkOption {
        description = "Enable clang Debug Adapter";
        type = bool;
        default = config.vim.languages.enableDAP;
        defaultText = literalExpression "config.vim.languages.enableDAP";
      };
      debugger = mkOption {
        description = "clang debugger to use";
        type =
          deprecatedSingleOrListOf "vim.languages.clang.dap.debugger"
          (enumWithRename "vim.languages.clang.dap.debugger" (attrNames dapConfigurations) {
            lldb-vscode = "lldb";
          });
        default = defaultDebugger;
      };
    };

    format = {
      enable =
        mkEnableOption "C formatting"
        // {
          default = config.vim.languages.enableFormat;
          defaultText = literalExpression "config.vim.languages.enableFormat";
        };

      type = mkOption {
        type = listOf (enum formats);
        default = defaultFormat;
        description = "C formatter to use";
      };
    };

    extraDiagnostics = {
      enable =
        mkEnableOption "extra C/C++ diagnostics via nvim-lint"
        // {
          default = config.vim.languages.enableExtraDiagnostics;
          defaultText = literalExpression "config.vim.languages.enableExtraDiagnostics";
        };

      types = mkOption {
        type = listOf (enum diagnosticsProviders);
        default = defaultDiagnosticsProvider;
        description = "extra C/C++ diagnostics providers";
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
      vim.lsp = {
        presets = genAttrs cfg.lsp.servers (_: {enable = true;});
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = ["c" "cpp" "objc" "objcpp" "cuda" "proto"];
        });
      };
    })

    (mkIf cfg.dap.enable {
      vim.debugger.nvim-dap = let
        conf = mkMerge (map (name: dapConfigurations.${name}) cfg.dap.debugger);
      in {
        enable = true;
        presets = genAttrs cfg.dap.debugger (_: {enable = true;});
        configurations = {
          c = conf;
          cpp = conf;
        };
      };
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        presets = genAttrs cfg.format.type (_: {enable = true;});
        setupOpts.formatters_by_ft = {
          c = cfg.format.type;
          cpp = cfg.format.type;
        };
      };
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.diagnostics = {
        presets = genAttrs cfg.extraDiagnostics.types (_: {enable = true;});
        nvim-lint = {
          enable = true;
          linters_by_ft = {
            c = cfg.extraDiagnostics.types;
            cpp = cfg.extraDiagnostics.types;
          };
        };
      };
    })
  ]);
}
