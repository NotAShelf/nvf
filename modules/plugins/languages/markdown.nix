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
  inherit (lib.types) bool enum package listOf str nullOr;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.types) diagnostics mkGrammarOption mkPluginSetupOption singleOrListOf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.markdown;
  defaultServers = ["marksman"];
  servers = {
    marksman = {
      enable = true;
      cmd = [(getExe pkgs.marksman) "server"];
      filetypes = ["markdown" "markdown.mdx"];
      root_markers = [".marksman.toml" ".git"];
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
      enable = mkEnableOption "Markdown LSP support" // {default = config.vim.lsp.enable;};

      servers = mkOption {
        description = "Markdown LSP server to use";
        type = singleOrListOf (enum (attrNames servers));
        default = defaultServers;
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

    (mkIf cfg.extensions.markview-nvim.enable {
      vim.startPlugins = ["markview-nvim"];
      vim.pluginRC.markview-nvim = entryAnywhere ''
        require("markview").setup(${toLuaObject cfg.extensions.markview-nvim.setupOpts})
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
