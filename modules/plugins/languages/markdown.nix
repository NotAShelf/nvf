{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.lists) isList;
  inherit (lib.types) bool enum either package listOf str;
  inherit (lib.nvim.lua) expToLua toLuaObject;
  inherit (lib.nvim.types) diagnostics mkGrammarOption mkPluginSetupOption;
  inherit (lib.nvim.dag) entryAnywhere;

  cfg = config.vim.languages.markdown;
  defaultServer = "marksman";
  servers = {
    marksman = {
      package = pkgs.marksman;
      lspConfig = ''
        lspconfig.marksman.setup{
          capabilities = capabilities;
          on_attach = default_on_attach;
          cmd = ${
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else ''{"${cfg.lsp.package}/bin/marksman", "server"}''
        },
        }
      '';
    };
  };

  defaultFormat = "deno_fmt";
  formats = {
    # for backwards compatibility
    denofmt = {
      package = pkgs.deno;
    };
    deno_fmt = {
      package = pkgs.deno;
    };
    prettierd = {
      package = pkgs.prettierd;
    };
  };
  defaultDiagnosticsProvider = ["markdownlint-cli2"];
  diagnosticsProviders = {
    markdownlint-cli2 = {
      package = pkgs.markdownlint-cli2;
    };
  };
in {
  options.vim.languages.markdown = {
    enable = mkEnableOption "Markdown markup language support";

    treesitter = {
      enable = mkOption {
        type = bool;
        default = config.vim.languages.enableTreesitter;
        description = "Enable Markdown treesitter";
      };
      mdPackage = mkGrammarOption pkgs "markdown";
      mdInlinePackage = mkGrammarOption pkgs "markdown-inline";
    };

    lsp = {
      enable = mkEnableOption "Enable Markdown LSP support" // {default = config.vim.languages.enableLSP;};

      server = mkOption {
        type = enum (attrNames servers);
        default = defaultServer;
        description = "Markdown LSP server to use";
      };

      package = mkOption {
        type = either package (listOf str);
        default = servers.${cfg.lsp.server}.package;
        example = ''[lib.getExe pkgs.jdt-language-server " - data " " ~/.cache/jdtls/workspace "]'';
        description = "Markdown LSP server package, or the command to run as a list of strings";
      };
    };

    format = {
      enable = mkEnableOption "Markdown formatting" // {default = config.vim.languages.enableFormat;};

      type = mkOption {
        type = enum (attrNames formats);
        default = defaultFormat;
        description = "Markdown formatter to use. `denofmt` is deprecated and currently aliased to deno_fmt.";
      };

      package = mkOption {
        type = package;
        default = formats.${cfg.format.type}.package;
        description = "Markdown formatter package";
      };

      extraFiletypes = mkOption {
        type = listOf str;
        default = [];
        description = "Extra filetypes to format with the Markdown formatter";
      };
    };

    extensions = {
      render-markdown-nvim = {
        enable =
          mkEnableOption ""
          // {
            description = ''
              [render-markdown.nvim]: https://github.com/MeanderingProgrammer/render-markdown.nvim

              Inline Markdown rendering with [render-markdown.nvim]
            '';
          };

        setupOpts = mkPluginSetupOption "render-markdown" {};
      };
    };

    extraDiagnostics = {
      enable = mkEnableOption "extra Markdown diagnostics" // {default = config.vim.languages.enableExtraDiagnostics;};
      types = diagnostics {
        langDesc = "Markdown";
        inherit diagnosticsProviders;
        inherit defaultDiagnosticsProvider;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.mdPackage cfg.treesitter.mdInlinePackage];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.markdown-lsp = servers.${cfg.lsp.server}.lspConfig;
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts.formatters_by_ft.markdown = [cfg.format.type];
        setupOpts.formatters.${
          if cfg.format.type == "denofmt"
          then "deno_fmt"
          else cfg.format.type
        } = {
          command = getExe cfg.format.package;
        };
      };
    })

    # Extensions
    (mkIf cfg.extensions.render-markdown-nvim.enable {
      vim.startPlugins = ["render-markdown-nvim"];
      vim.pluginRC.render-markdown-nvim = entryAnywhere ''
        require("render-markdown").setup(${toLuaObject cfg.extensions.render-markdown-nvim.setupOpts})
      '';
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.diagnostics.nvim-lint = {
        enable = true;
        linters_by_ft.markdown = cfg.extraDiagnostics.types;
        linters = mkMerge (map (name: {
            ${name}.cmd = getExe diagnosticsProviders.${name}.package;
          })
          cfg.extraDiagnostics.types);
      };
    })
  ]);
}
