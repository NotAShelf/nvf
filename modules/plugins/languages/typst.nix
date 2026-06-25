{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption literalExpression;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) nullOr enum attrsOf listOf str bool int;
  inherit (lib.attrsets) attrNames;
  inherit (lib) genAttrs;
  inherit (lib.meta) getExe;
  inherit (lib.nvim.types) mkGrammarOption mkPluginSetupOption deprecatedSingleOrListOf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.attrsets) mapListToAttrs;
  inherit (lib.nvim.binds) mkKeymap;
  inherit (config.vim.lib) mkMappingOption;

  cfg = config.vim.languages.typst;

  defaultServers = ["tinymist"];
  servers = ["tinymist"];

  defaultFormat = ["typstyle"];
  formats = {
    # https://github.com/Enter-tainer/typstyle
    typstyle = {
      command = getExe pkgs.typstyle;
    };
  };
in {
  options.vim.languages.typst = {
    enable = mkEnableOption "Typst language support";

    treesitter = {
      enable =
        mkEnableOption "Typst treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "typst";
    };

    lsp = {
      enable =
        mkEnableOption "Typst LSP support (typst-lsp)"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };

      servers = mkOption {
        type = listOf (enum servers);
        default = defaultServers;
        description = "Typst LSP server to use";
      };
    };

    format = {
      enable =
        mkEnableOption "Typst document formatting"
        // {
          default = config.vim.languages.enableFormat;
          defaultText = literalExpression "config.vim.languages.enableFormat";
        };

      type = mkOption {
        type = deprecatedSingleOrListOf "vim.language.typst.format.type" (enum (attrNames formats));
        default = defaultFormat;
        description = "Typst formatter to use";
      };
    };

    extensions = {
      typst-preview-nvim = {
        enable =
          mkEnableOption ''
            [typst-preview.nvim]: https://github.com/chomosuke/typst-preview.nvim

            Low latency typst preview for Neovim via [typst-preview.nvim]
          ''
          // {default = true;};

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
              "tinymist" = getExe pkgs.tinymist;
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
      typst-concealer = {
        enable = mkEnableOption ''
          [typst-concealer]: https://github.com/PartyWumpus/typst-concealer

          Inline typst preview for Neovim via [typst-concealer]
        '';

        mappings = {
          toggleConcealing = mkMappingOption "Enable typst-concealer in buffer" "<leader>TT";
        };

        setupOpts = mkPluginSetupOption "typst-concealer" {
          do_diagnostics = mkOption {
            type = nullOr bool;
            default = !cfg.lsp.enable;
            description = "Should typst-concealer provide diagnostics on error?";
          };
          color = mkOption {
            type = nullOr str;
            default = null;
            example = "rgb(\"#f012be\")";
            description = "What color should typst-concealer render text/stroke with? (only applies when styling_type is 'colorscheme')";
          };
          enabled_by_default = mkOption {
            type = nullOr bool;
            default = null;
            description = "Should typst-concealer conceal newly opened buffers by default?";
          };
          styling_type = mkOption {
            type = nullOr (enum ["simple" "none" "colorscheme"]);
            default = null;
            description = "What kind of styling should typst-concealer apply to your typst?";
          };
          ppi = mkOption {
            type = nullOr int;
            default = null;
            description = "What PPI should typst render at. Plugin default is 300, typst's normal default is 144.";
          };
          typst_location = mkOption {
            type = str;
            default = getExe pkgs.typst;
            description = "Where should typst-concealer look for your typst binary?";
            example = ''lib.getExe pkgs.typst'';
          };
          conceal_in_normal = mkOption {
            type = nullOr bool;
            default = null;
            description = "Should typst-concealer still conceal when the normal mode cursor goes over a line.";
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
        setupOpts = {
          formatters_by_ft.typst = cfg.format.type;
          formatters =
            mapListToAttrs (name: {
              inherit name;
              value = formats.${name};
            })
            cfg.format.type;
        };
      };
    })

    (mkIf cfg.lsp.enable {
      vim.lsp = {
        presets = genAttrs cfg.lsp.servers (_: {enable = true;});
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = ["typst"];
        });
      };
    })

    # Extensions
    (mkIf cfg.extensions.typst-preview-nvim.enable {
      vim.startPlugins = ["typst-preview-nvim"];
      vim.pluginRC.typst-preview-nvim = entryAnywhere ''
        require("typst-preview").setup(${toLuaObject cfg.extensions.typst-preview-nvim.setupOpts})
      '';
    })

    (mkIf cfg.extensions.typst-concealer.enable {
      vim.lazy.plugins.typst-concealer = {
        event = "BufRead *.typ";
        package = "typst-concealer";
        setupModule = "typst-concealer";
        setupOpts = cfg.extensions.typst-concealer.setupOpts;

        keys = [
          (mkKeymap "n" cfg.extensions.typst-concealer.mappings.toggleConcealing "<cmd>lua require('typst-concealer').toggle_buf()<CR>" {desc = "Toggle typst-concealer in buffer";})
        ];
      };
    })
  ]);
}
