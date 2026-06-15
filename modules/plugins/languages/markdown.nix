{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) genAttrs;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) literalExpression mkEnableOption mkOption;
  inherit (lib.types) bool enum listOf str nullOr;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.types) mkGrammarOption mkPluginSetupOption deprecatedSingleOrListOf enumWithRename;
  inherit (lib.nvim.dag) entryAnywhere;

  cfg = config.vim.languages.markdown;
  defaultServers = ["marksman"];
  servers = ["marksman" "markdown-oxide" "rumdl"];

  defaultFormat = ["deno"];
  formats = ["deno" "prettier" "rumdl" "mdformat"];
  defaultDiagnosticsProvider = ["markdownlint-cli2"];
  diagnosticsProviders = ["markdownlint-cli2" "rumdl"];
in {
  options.vim.languages.markdown = {
    enable = mkEnableOption "Markdown markup language support";

    treesitter = {
      enable = mkOption {
        type = bool;
        default = config.vim.languages.enableTreesitter;
        defaultText = literalExpression "config.vim.languages.enableTreesitter";
        description = "Enable Markdown treesitter";
      };
      mdPackage = mkGrammarOption pkgs "markdown";
      mdInlinePackage = mkGrammarOption pkgs "markdown_inline";
    };

    lsp = {
      enable =
        mkEnableOption "Markdown LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };

      servers = mkOption {
        description = "Markdown LSP server to use";
        type = listOf (enum servers);
        default = defaultServers;
      };
    };

    format = {
      enable =
        mkEnableOption "Markdown formatting"
        // {
          default = config.vim.languages.enableFormat;
          defaultText = literalExpression "config.vim.languages.enableFormat";
        };

      type = mkOption {
        type =
          deprecatedSingleOrListOf
          "vim.languages.markdown.format.type"
          (enumWithRename
            "vim.languages.markdown.format.type"
            formats
            {
              denofmt = "deno";
              deno_fmt = "deno";
              prettierd = "prettier";
            });
        default = defaultFormat;
        description = "Markdown formatter to use";
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

        setupOpts = mkPluginSetupOption "render-markdown" {
          file_types = lib.mkOption {
            type = nullOr (listOf str);
            default = null;
            description = ''
              List of buffer filetypes to enable this plugin in.

              This will cause the plugin to attach to new buffers who
              have any of these filetypes.
            '';
          };
        };
      };
      markview-nvim = {
        enable =
          mkEnableOption ""
          // {
            description = ''
              [markview.nvim]: https://github.com/OXY2DEV/markview.nvim

              [markview.nvim] - a hackable markdown, Typst, latex, html(inline) & YAML previewer
            '';
          };
        setupOpts = mkPluginSetupOption "markview-nvim" {};
      };
    };

    extraDiagnostics = {
      enable =
        mkEnableOption "extra Markdown diagnostics via nvim-lint"
        // {
          default = config.vim.languages.enableExtraDiagnostics;
          defaultText = literalExpression "config.vim.languages.enableExtraDiagnostics";
        };
      types = mkOption {
        type = listOf (enum diagnosticsProviders);
        default = defaultDiagnosticsProvider;
        description = "extra Markdown diagnostics providers";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      vim.filetype.extension.mdx = "markdown";
    }

    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.mdPackage cfg.treesitter.mdInlinePackage];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp = {
        presets = genAttrs cfg.lsp.servers (_: {enable = true;});
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = ["markdown"];
        });
      };
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        presets = genAttrs cfg.format.type (_: {enable = true;});
        setupOpts.formatters_by_ft.markdown = cfg.format.type;
      };
    })

    # Extensions
    (mkIf cfg.extensions.render-markdown-nvim.enable {
      vim.startPlugins = ["render-markdown-nvim"];
      vim.pluginRC.render-markdown-nvim = entryAnywhere ''
        require("render-markdown").setup(${toLuaObject cfg.extensions.render-markdown-nvim.setupOpts})
      '';
    })

    (mkIf cfg.extensions.markview-nvim.enable {
      vim.startPlugins = ["markview-nvim"];
      vim.pluginRC.markview-nvim = entryAnywhere ''
        require("markview").setup(${toLuaObject cfg.extensions.markview-nvim.setupOpts})
      '';
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.diagnostics = {
        presets = genAttrs cfg.extraDiagnostics.types (_: {enable = true;});
        nvim-lint = {
          enable = true;
          linters_by_ft.markdown = cfg.extraDiagnostics.types;
        };
      };
    })
  ]);
}
