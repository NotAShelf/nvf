{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) enum package;
  inherit (lib.nvim.dag) entryAfter;
  inherit (lib.meta) getExe;
  inherit (lib.nvim.types) mkGrammarOption deprecatedSingleOrListOf;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.odin;

  defaultServers = ["ols"];
  servers = {
    ols = {
      enable = true;
      cmd = [(getExe pkgs.ols)];
      filetypes = ["odin"];
      root_dir =
        mkLuaInline
        /*
        lua
        */
        ''
          function(bufnr, on_dir)
            local fname = vim.api.nvim_buf_get_name(bufnr)
            on_dir(util.root_pattern('ols.json', '.git', '*.odin')(fname))
          end'';
    };
  };

  defaultDebugger = "codelldb";
  debuggers = {
    codelldb = {
      package = pkgs.lldb;
      dapConfig = ''
        dap.adapters.codelldb = {
          type = 'executable',
          command = '${cfg.dap.package}/bin/lldb-dap',
          name = 'codelldb'
        }
      '';
    };
  };
in {
  options.vim.languages.odin = {
    enable = mkEnableOption "Odin language support";

    treesitter = {
      enable = mkEnableOption "Odin treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "odin";
    };

    lsp = {
      enable = mkEnableOption "Odin LSP support" // {default = config.vim.lsp.enable;};

      servers = mkOption {
        type = deprecatedSingleOrListOf "vim.language.odin.lsp.servers" (enum (attrNames servers));
        default = defaultServers;
        description = "Odin LSP server to use";
      };
    };

    dap = {
      enable = mkEnableOption "Enable Odin Debug Adapter" // {default = config.vim.languages.enableDAP;};

      debugger = mkOption {
        description = "Odin debugger to use";
        type = enum (attrNames debuggers);
        default = defaultDebugger;
      };

      package = mkOption {
        description = "Odin debugger package.";
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
      vim.lsp.servers =
        mapListToAttrs (n: {
          name = n;
          value = servers.${n};
        })
        cfg.lsp.servers;
    })

    (mkIf cfg.dap.enable {
      vim = {
        startPlugins = ["nvim-dap-odin"];
        debugger.nvim-dap.sources.odin-debugger = debuggers.${cfg.dap.debugger}.dapConfig;
        pluginRC.nvim-dap-odin = entryAfter ["nvim-dap"] ''
          require('nvim-dap-odin').setup({
            notifications = false -- contains no useful information
          })
        '';
        debugger.nvim-dap.enable = true;
      };
    })
  ]);
}
