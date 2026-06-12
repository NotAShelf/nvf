{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) enum listOf;
  inherit (lib.attrsets) genAttrs;
  inherit (lib.lists) flatten;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.types) mkGrammarOption deprecatedSingleOrListOf enumWithRename;

  cfg = config.vim.languages.odin;

  defaultServers = ["ols"];
  servers = ["ols"];
  defaultDebugger = ["lldb"];
  dapConfigurations = {
    lldb = [
      {
        name = "Launch";
        type = "lldb";
        request = "launch";
        program = mkLuaInline ''
          function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end
        '';
        cwd = "\${workspaceFolder}";
        stopOnEntry = false;
        args = [];
      }
    ];
  };
in {
  options.vim.languages.odin = {
    enable = mkEnableOption "Odin language support";

    treesitter = {
      enable =
        mkEnableOption "Odin treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "odin";
    };

    lsp = {
      enable =
        mkEnableOption "Odin LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };

      servers = mkOption {
        type = listOf (enum servers);
        default = defaultServers;
        description = "Odin LSP server to use";
      };
    };

    dap = {
      enable =
        mkEnableOption "Enable Odin Debug Adapter"
        // {
          default = config.vim.languages.enableDAP;
          defaultText = literalExpression "config.vim.languages.enableDAP";
        };

      debugger = mkOption {
        description = "Odin debugger to use";
        type =
          deprecatedSingleOrListOf "vim.languages.clang.dap.debugger"
          (enumWithRename "vim.languages.clang.dap.debugger" (attrNames dapConfigurations) {
            codelldb = "lldb";
          });

        default = defaultDebugger;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp = {
        presets = genAttrs cfg.lsp.servers (_: {enable = true;});
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = ["odin"];
        });
      };
    })

    (mkIf cfg.dap.enable {
      vim.debugger.nvim-dap = {
        enable = true;
        presets = mkMerge (map (name: {${name}.enable = true;}) cfg.dap.debugger);
        configurations.odin = flatten (map (name: dapConfigurations.${name}) cfg.dap.debugger);
      };
    })
  ]);
}
