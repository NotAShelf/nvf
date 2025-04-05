{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) isList attrNames;
  inherit (lib.modules) mkIf mkMerge;

  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) nullOr enum either attrsOf listOf package str;
  inherit (lib.meta) getExe;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.languages) lspOptions;
  inherit (lib.nvim.lua) expToLua toLuaObject;
  inherit (lib.nvim.types) mkGrammarOption mkPluginSetupOption;
  inherit (lib.nvim.dag) entryAnywhere;

  cfg = config.vim.languages.typst;

  defaultServer = "tinymist";
  servers = {
    typst-lsp = {
      package = pkgs.typst-lsp;
      options = {
        on_attach = mkLuaInline ''
          function(client, bufnr)
            -- Disable semantic tokens as a workaround for a semantic token error
            -- when using non-english characters
            client.server_capabilities.semanticTokensProvider = nil
          end,
        '';

        cmd =
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else ''{"${getExe cfg.lsp.package}'';
      };
    };

    tinymist = {
      package = pkgs.tinymist;
      options = {
        on_attach = mkLuaInline ''
          function(client, bufnr)
            -- Disable semantic tokens as a workaround for a semantic token error
            -- when using non-english characters
            client.server_capabilities.semanticTokensProvider = nil
          end,
        '';

        cmd =
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else ''{"${cfg.lsp.package}/bin/tinymist"}'';
      };
    };
  };

  defaultFormat = "typstfmt";
  formats = {
    typstfmt = {
      package = pkgs.typstfmt;
    };
    # https://github.com/Enter-tainer/typstyle
    typstyle = {
      package = pkgs.typstyle;
    };
  };
in {
  options.vim.languages.typst = {
    enable = mkEnableOption "Typst language support";

    treesitter = {
      enable = mkEnableOption "Typst treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "typst";
    };

    lsp = {
      enable = mkEnableOption "Typst LSP support (typst-lsp)" // {default = config.vim.languages.enableLSP;};

      server = mkOption {
        type = listOf (enum (attrNames servers));
        default = defaultServer;
        description = "Typst LSP server to use";
      };

      package = mkOption {
        type = either package (listOf str);
        default = servers.${cfg.lsp.server}.package;
        example = ''[lib.getExe pkgs.jdt-language-server "-data" "~/.cache/jdtls/workspace"]'';
        description = "typst-lsp package, or the command to run as a list of strings";
      };
    };

    format = {
      enable = mkEnableOption "Typst document formatting" // {default = config.vim.languages.enableFormat;};
      type = mkOption {
        type = enum (attrNames formats);
        default = defaultFormat;
        description = "Typst formatter to use";
      };

      package = mkOption {
        type = package;
        default = formats.${cfg.format.type}.package;
        description = "Typst formatter package";
      };
    };

    extensions = {
      typst-preview-nvim = {
        enable =
          mkEnableOption ""
          // {
            default = true;
            description = ''
              [typst-preview.nvim]: https://github.com/chomosuke/typst-preview.nvim

              Low latency typst preview for Neovim via [typst-preview.nvim]
            '';
          };

        setupOpts = mkPluginSetupOption "typst-preview-nvim" {
          open_cmd = mkOption {
            type = nullOr str;
            default = null;
            example = "firefox %s -P typst-preview --class typst-preview";
            description = ''
              Custom format string to open the output link provided with `%s`
            '';
          };

          dependencies_bin = mkOption {
            type = attrsOf str;
            default = {
              "tinymist" = getExe servers.tinymist.package;
              "websocat" = getExe pkgs.websocat;
            };

            description = ''
              Provide the path to binaries for dependencies. Setting this
              to a non-null value will skip the download of the binary by
              the plugin.
            '';
          };

          extra_args = mkOption {
            type = nullOr (listOf str);
            default = null;
            example = ["--input=ver=draft" "--ignore-system-fonts"];
            description = "A list of extra arguments (or `null`) to be passed to previewer";
          };
        };
      };
    };
  };
  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts.formatters_by_ft.typst = [cfg.format.type];
        setupOpts.formatters.${cfg.format.type} = {
          command = getExe cfg.format.package;
        };
      };
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.typst-lsp = servers.${cfg.lsp.server}.lspConfig;
    })

    # Extensions
    (mkIf cfg.extensions.typst-preview-nvim.enable {
      vim.startPlugins = ["typst-preview-nvim"];
      vim.pluginRC.typst-preview-nvim = entryAnywhere ''
        require("typst-preview").setup(${toLuaObject cfg.extensions.typst-preview-nvim.setupOpts})
      '';
    })
  ]);
}
