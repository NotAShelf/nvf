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
  inherit (lib.generators) mkLuaInline;
  inherit (lib.types) bool enum package;
  inherit (lib.nvim.types) mkGrammarOption singleOrListOf;
  inherit (lib.nvim.dag) entryAfter;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.go;

  defaultServers = ["gopls"];
  servers = {
    gopls = {
      cmd = [(getExe pkgs.gopls)];
      filetypes = ["go" "gomod" "gowork" "gotmpl"];
      root_dir = mkLuaInline ''
        function(bufnr, on_dir)
          local fname = vim.api.nvim_buf_get_name(bufnr)

          local function get_root(fname)
            if _G.nvf_gopls_mod_cache and fname:sub(1, #_G.nvf_gopls_mod_cache) == _G.nvf_gopls_mod_cache then
              local clients = vim.lsp.get_clients { name = 'gopls' }
              if #clients > 0 then
                return clients[#clients].config.root_dir
              end
            end
            return vim.fs.root(fname, 'go.work') or vim.fs.root(fname, 'go.mod') or vim.fs.root(fname, '.git')
          end

          -- see: https://github.com/neovim/nvim-lspconfig/issues/804
          if _G.nvf_gopls_mod_cache then
            on_dir(get_root(fname))
            return
          end
          local cmd = { 'go', 'env', 'GOMODCACHE' }
          local ok, err = pcall(vim.system, cmd, { text = true }, function(output)
            if output.code == 0 then
              if output.stdout then
                _G.nvf_gopls_mod_cache = vim.trim(output.stdout)
              end
              on_dir(get_root(fname))
            else
              vim.schedule(function()
                vim.notify(('[gopls] cmd failed with code %d: %s\n%s'):format(output.code, cmd, output.stderr))
              end)
            end
          end)
          if not ok then vim.notify(('[gopls] cmd failed: %s\n%s'):format(cmd, err)) end
        end
      '';
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

      servers = mkOption {
        type = singleOrListOf (enum (attrNames servers));
        default = defaultServers;
        description = "Go LSP server to use";
      };
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
        mapListToAttrs (name: {
          inherit name;
          value = servers.${name};
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
