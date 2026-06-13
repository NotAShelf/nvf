{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.modules) mkIf mkMerge mkDefault;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.attrsets) genAttrs;
  inherit (lib.lists) flatten;
  inherit (lib.types) bool enum listOf;
  inherit (lib.nvim.types) mkGrammarOption deprecatedSingleOrListOf enumWithRename;

  cfg = config.vim.languages.zig;

  defaultServers = ["zls"];
  servers = ["zls"];

  defaultDebugger = ["lldb"];
  dapConfigurations = {
    lldb = let
      baseConfig = {
        name = "Launch";
        type = "lldb";
        request = "launch";
        program = mkLuaInline ''
          function()
            return nvf_dap_cached_input(
              'zig_lldb_launch_exe',
              'Path to executable: ',
              vim.fn.getcwd() .. '/',
              'file'
            )
          end
        '';
        cwd = "\${workspaceFolder}";
        stopOnEntry = false;
        args = [];
      };
    in [
      baseConfig
      (baseConfig
        // {
          name = "Launch with console";
          console = "integratedTerminal";
        })
    ];
  };
in {
  options.vim.languages.zig = {
    enable = mkEnableOption "Zig language support";

    treesitter = {
      enable =
        mkEnableOption "Zig treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "zig";
    };

    lsp = {
      enable =
        mkEnableOption "Zig LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };

      servers = mkOption {
        type = listOf (enum servers);
        default = defaultServers;
        description = "Zig LSP server to use";
      };
    };

    dap = {
      enable = mkOption {
        type = bool;
        default = config.vim.languages.enableDAP;
        defaultText = literalExpression "config.vim.languages.enableDAP";
        description = "Enable Zig Debug Adapter";
      };

      debugger = mkOption {
        type =
          deprecatedSingleOrListOf "vim.languages.zig.dap.debugger"
          (enumWithRename "vim.languages.zig.dap.debugger" (attrNames dapConfigurations) {
            lldb-vscode = "lldb";
          });
        default = defaultDebugger;
        description = "Zig debugger to use";
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
        lsp = {
          presets = genAttrs cfg.lsp.servers (_: {enable = true;});
          servers = genAttrs cfg.lsp.servers (_: {
            root_markers = ["build.zig"];
            filetypes = ["zig" "zir"];
          });
        };
        # nvf handles autosaving already
        globals.zig_fmt_autosave = mkDefault 0;
      };
    })

    (mkIf cfg.dap.enable {
      vim.debugger.nvim-dap = {
        enable = true;
        presets = mkMerge (map (name: {${name}.enable = true;}) cfg.dap.debugger);
        configurations.zig = flatten (map (name: dapConfigurations.${name}) cfg.dap.debugger);
      };
    })
  ]);
}
