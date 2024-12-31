{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.lists) isList concatLists;
  inherit (lib.types) bool enum either package listOf str;
  inherit (lib.nvim.lua) expToLua toLuaObject;
  inherit (lib.nvim.types) mkGrammarOption mkPluginSetupOption;
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

  defaultFormat = "denofmt";
  formats = {
    denofmt = {
      package = pkgs.deno;
      nullConfig = ''
        table.insert(
          ls_sources,
          null_ls.builtins.formatting.deno_fmt.with({
            filetypes = ${expToLua (concatLists [cfg.format.extraFiletypes ["markdown"]])},
            command = "${cfg.format.package}/bin/deno",
          })
        )
      '';
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
        description = "Markdown formatter to use";
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
          auto_override_publish_diagnostics = mkOption {
            description = "Automatically override the publish_diagnostics handler";
            type = bool;
            default = true;
          };
        };
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
      vim.lsp.null-ls.enable = true;
      vim.lsp.null-ls.sources.markdown-format = formats.${cfg.format.type}.nullConfig;
    })

    # Extensions
    (mkIf cfg.extensions.render-markdown-nvim.enable {
      vim.startPlugins = ["render-markdown-nvim"];
      vim.pluginRC.render-markdown-nvim = entryAnywhere ''
        require("render-markdown").setup(${toLuaObject cfg.extensions.render-markdown-nvim.setupOpts})
      '';
    })
  ]);
}
