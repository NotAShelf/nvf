{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption literalMD;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.meta) getExe;
  inherit (lib.types) bool enum package;
  inherit (lib.nvim.attrsets) mapListToAttrs;
  inherit (lib.nvim.types) mkGrammarOption mkServersOption;
  inherit (lib.nvim.dag) entryAfter;

  cfg = config.vim.languages.go;

  defaultServers = ["gopls"];
  servers = {
    gopls = {
      enable = true;
      cmd = [(getExe pkgs.gopls) "serve"];
      filetypes = ["go" "gomod"];
      root_markers = ["go.mod" ".git"];
    };
  };

  defaultFormat = "gofmt";
  formats = {
    gofmt = {
      package = pkgs.go;
      config.command = "${cfg.format.package}/bin/gofmt";
    };
    gofumpt = {
      package = pkgs.gofumpt;
      config.command = getExe cfg.format.package;
    };
    golines = {
      package = pkgs.golines;
      config.command = "${cfg.format.package}/bin/golines";
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
      enable = mkEnableOption "Go LSP support" // {default = config.vim.lsp.enable;};
      servers = mkServersOption "Go" servers defaultServers;
    };

    format = {
      enable =
        mkEnableOption "Go formatting"
        // {
          default = !cfg.lsp.enable && config.vim.languages.enableFormat;
          defaultText = literalMD ''
            disabled if Go LSP is enabled, otherwise follows {option}`vim.languages.enableFormat`
          '';
        };

      type = mkOption {
        description = "Go formatter to use";
        type = enum (attrNames formats);
        default = defaultFormat;
      };

      package = mkOption {
        description = "Go formatter package";
        type = package;
        default = formats.${cfg.format.type}.package;
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
      vim.lsp.servers =
        mapListToAttrs (n: {
          name = n;
          value = servers.${n};
        })
        cfg.lsp.servers;
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts.formatters_by_ft.go = [cfg.format.type];
        setupOpts.formatters.${cfg.format.type} = formats.${cfg.format.type}.config;
      };
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
