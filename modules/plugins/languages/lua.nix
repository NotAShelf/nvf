{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.meta) getExe;
  inherit (lib.lists) isList;
  inherit (lib.types) bool either enum listOf package str;
  inherit (lib.nvim.types) diagnostics mkGrammarOption;
  inherit (lib.nvim.lua) expToLua;
  inherit (lib.nvim.dag) entryBefore;

  cfg = config.vim.languages.lua;
  defaultFormat = "stylua";
  formats = {
    stylua = {
      package = pkgs.stylua;
    };
  };

  defaultDiagnosticsProvider = ["luacheck"];
  diagnosticsProviders = {
    luacheck = {
      package = pkgs.luajitPackages.luacheck;
    };
  };
in {
  imports = [
    (lib.mkRemovedOptionModule ["vim" "languages" "lua" "lsp" "neodev"] ''
      neodev has been replaced by lazydev
    '')
  ];

  options.vim.languages.lua = {
    enable = mkEnableOption "Lua language support";
    treesitter = {
      enable = mkEnableOption "Lua Treesitter support" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "lua";
    };

    lsp = {
      enable = mkEnableOption "Lua LSP support via LuaLS" // {default = config.vim.languages.enableLSP;};

      package = mkOption {
        description = "LuaLS package, or the command to run as a list of strings";
        type = either package (listOf str);
        default = pkgs.lua-language-server;
      };

      lazydev.enable = mkEnableOption "lazydev.nvim integration, useful for neovim plugin developers";
    };

    format = {
      enable = mkOption {
        type = bool;
        default = config.vim.languages.enableFormat;
        description = "Enable Lua formatting";
      };
      type = mkOption {
        type = enum (attrNames formats);
        default = defaultFormat;
        description = "Lua formatter to use";
      };

      package = mkOption {
        type = package;
        default = formats.${cfg.format.type}.package;
        description = "Lua formatter package";
      };
    };

    extraDiagnostics = {
      enable = mkEnableOption "extra Lua diagnostics" // {default = config.vim.languages.enableExtraDiagnostics;};
      types = diagnostics {
        langDesc = "Lua";
        inherit diagnosticsProviders;
        inherit defaultDiagnosticsProvider;
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.enable (mkMerge [
      (mkIf cfg.lsp.enable {
        vim.lsp.lspconfig.enable = true;
        vim.lsp.lspconfig.sources.lua-lsp = ''
          lspconfig.lua_ls.setup {
            capabilities = capabilities;
            on_attach = default_on_attach;
            cmd = ${
            if isList cfg.lsp.package
            then expToLua cfg.lsp.package
            else ''{"${getExe cfg.lsp.package}"}''
          };
          }
        '';
      })

      (mkIf cfg.lsp.lazydev.enable {
        vim.startPlugins = ["lazydev-nvim"];
        vim.pluginRC.lazydev = entryBefore ["lua-lsp"] ''
          require("lazydev").setup({
            enabled = function(root_dir)
              return not vim.uv.fs_stat(root_dir .. "/.luarc.json")
            end,
            library = { { path = "''${3rd}/luv/library", words = { "vim%.uv" } } },
          })
        '';
      })

      (mkIf cfg.format.enable {
        vim.formatter.conform-nvim = {
          enable = true;
          setupOpts.formatters_by_ft.lua = [cfg.format.type];
          setupOpts.formatters.${cfg.format.type} = {
            command = getExe cfg.format.package;
          };
        };
      })

      (mkIf cfg.extraDiagnostics.enable {
        vim.diagnostics.nvim-lint = {
          enable = true;
          linters_by_ft.lua = cfg.extraDiagnostics.types;
          linters = mkMerge (map (name: {
              ${name}.cmd = getExe diagnosticsProviders.${name}.package;
            })
            cfg.extraDiagnostics.types);
        };
      })
    ]))
  ];
}
