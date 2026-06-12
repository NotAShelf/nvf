{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.types) bool enum package listOf;
  inherit (lib) genAttrs;
  inherit (lib.meta) getExe getExe';
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.types) mkGrammarOption;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.dag) entryAfter;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.clang;

  defaultServers = ["clangd"];
  servers = ["ccls" "clangd"];

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

  defaultFormat = ["clang-format"];
  formats = {
    astyle = {
      command = getExe pkgs.astyle;
      stdin = false;
      args = mkLuaInline ''
        function(self, ctx)
          local args = {
            "$FILENAME",
          }

          if not vim.bo[ctx.buf].expandtab then
            table.insert(args, "--indent=tab=" .. ctx.shiftwidth)
          else
            table.insert(args, "--indent=spaces=" .. ctx.shiftwidth)
          end

          return args
        end
      '';
    };
    indent = {
      command = getExe pkgs.indent;
      stdin = true;
      args = mkLuaInline ''
        function(self, ctx)
          local args = {
            "--indent-level", ctx.shiftwidth,
            "--tab-size", ctx.shiftwidth,
          }

          if not vim.bo[ctx.buf].expandtab then
            table.insert(args, "--use-tabs")
          else
            table.insert(args, "--no-tabs")
          end

          return args
        end
      '';
      # Default is GNU style. Nobody likes that one.
      # This is under `append_args`, to allow easy editing of this argument,
      # without having to redefine everything as a user.
      append_args = ["--linux-style"];
    };
    clang-format.command = getExe' pkgs.clang-tools "clang-format";
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
        type = enum (attrNames debuggers);
        default = defaultDebugger;
      };
      package = mkOption {
        description = "clang debugger package.";
        type = package;
        default = debuggers.${cfg.dap.debugger}.package;
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
        type = listOf (enum (attrNames formats));
        default = defaultFormat;
        description = "C formatter to use";
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
      vim.debugger.nvim-dap.enable = true;
      vim.debugger.nvim-dap.sources.clang-debugger = debuggers.${cfg.dap.debugger}.dapConfig;
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts = {
          formatters_by_ft = {
            c = cfg.format.type;
            cpp = cfg.format.type;
          };
          formatters =
            mapListToAttrs (name: {
              inherit name;
              value = formats.${name};
            })
            cfg.format.type;
        };
      };
    })
  ]);
}
