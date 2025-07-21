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
  inherit (lib.types) bool enum listOf package;
  inherit (lib.nvim.types) diagnostics mkGrammarOption mkServersOption;
  inherit (lib.nvim.dag) entryBefore;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.lua;

  defaultServers = ["lua-language-server"];
  servers = {
    lua-language-server = {
      enable = true;
      cmd = [(getExe pkgs.lua-language-server)];
      filetypes = ["lua"];
      root_markers = [
        ".luarc.json"
        ".luarc.jsonc"
        ".luacheckrc"
        ".stylua.toml"
        "stylua.toml"
        "selene.toml"
        "selene.yml"
        ".git"
      ];
    };
  };

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
      enable = mkEnableOption "Lua LSP support" // {default = config.vim.lsp.enable;};
      servers = mkServersOption "Lua" servers defaultServers;

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
        vim.lsp.servers =
          mapListToAttrs (n: {
            name = n;
            value = servers.${n};
          })
          cfg.lsp.servers;
      })

      (mkIf cfg.lsp.lazydev.enable {
        vim.startPlugins = ["lazydev-nvim"];
        vim.pluginRC.lazydev = entryBefore ["lsp-servers"] ''
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
