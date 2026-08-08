{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) literalExpression mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib) genAttrs;
  inherit (lib.types) enum listOf;
  inherit (lib.nvim.types) mkGrammarOption mkPluginSetupOption;

  cfg = config.vim.languages.lua;

  defaultServers = ["lua-language-server"];
  servers = ["lua-language-server"];

  defaultFormat = ["stylua"];
  formats = ["stylua" "injected"];

  defaultDiagnosticsProvider = ["luacheck"];
  diagnosticsProviders = ["luacheck" "selene"];
in {
  imports = [
    (lib.mkRemovedOptionModule ["vim" "languages" "lua" "lsp" "neodev"] ''
      neodev has been replaced by lazydev
    '')
  ];

  options.vim.languages.lua = {
    enable = mkEnableOption "Lua language support";
    treesitter = {
      enable =
        mkEnableOption "Lua Treesitter support"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "lua";
    };

    lsp = {
      enable =
        mkEnableOption "Lua LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };
      servers = mkOption {
        type = listOf (enum servers);
        default = defaultServers;
        description = "Lua LSP server to use";
      };
    };

    format = {
      enable =
        mkEnableOption "Lua formatting"
        // {
          default = config.vim.languages.enableFormat;
          defaultText = literalExpression "config.vim.languages.enableFormat";
        };
      type = mkOption {
        type = listOf (enum formats);
        default = defaultFormat;
        description = "Lua formatter to use";
      };
    };

    extraDiagnostics = {
      enable =
        mkEnableOption "extra Lua diagnostics via nvim-lint"
        // {
          default = config.vim.languages.enableExtraDiagnostics;
          defaultText = literalExpression "config.vim.languages.enableExtraDiagnostics";
        };
      types = mkOption {
        type = listOf (enum diagnosticsProviders);
        default = defaultDiagnosticsProvider;
        description = "extra Lua diagnostics providers";
      };
    };

    extensions = {
      lazydev = {
        enable = mkEnableOption "lazydev.nvim integration, useful for neovim plugin developers";
        setupOpts = mkPluginSetupOption "lazydev" {};
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
          filetypes = ["lua"];
        });
      };
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        presets = genAttrs cfg.format.type (_: {enable = true;});
        setupOpts.formatters_by_ft.lua = cfg.format.type;
      };
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.diagnostics = {
        presets = genAttrs cfg.extraDiagnostics.types (_: {enable = true;});
        nvim-lint = {
          enable = true;
          linters_by_ft.lua = cfg.extraDiagnostics.types;
        };
      };
    })

    (mkIf cfg.extensions.lazydev.enable {
      vim.lazy.plugins.lazydev = {
        package = "lazydev-nvim";
        setupModule = "lazydev";
        ft = "lua";
        inherit (cfg.extensions.lazydev) setupOpts;
      };
    })
  ]);
}
