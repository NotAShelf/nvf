{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) nullOr enum attrsOf listOf package str bool int;
  inherit (lib.attrsets) attrNames;
  inherit (lib.meta) getExe;
  inherit (lib.nvim.types) mkGrammarOption mkPluginSetupOption deprecatedSingleOrListOf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.attrsets) mapListToAttrs;
  inherit (lib.nvim.binds) mkKeymap mkMappingOption;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.languages.typst;

  defaultServers = ["tinymist"];
  servers = {
    typst_lsp = {
      enable = true;
      cmd = [(getExe pkgs.typst-lsp)];
      filetypes = ["typst"];
      root_markers = [".git"];
      on_attach = mkLuaInline ''
        function(client, bufnr)
          -- Disable semantic tokens as a workaround for a semantic token error when using non-english characters
          client.server_capabilities.semanticTokensProvider = nil
        end
      '';
    };

    tinymist = {
      enable = true;
      cmd = [(getExe pkgs.tinymist)];
      filetypes = ["typst"];
      root_markers = [".git"];
      on_attach = mkLuaInline ''
        function(client, bufnr)
          local function create_tinymist_command(command_name, client, bufnr)
            local export_type = command_name:match 'tinymist%.export(%w+)'
            local info_type = command_name:match 'tinymist%.(%w+)'
            if info_type and info_type:match '^get' then
              info_type = info_type:gsub('^get', 'Get')
            end
            local cmd_display = export_type or info_type
            local function run_tinymist_command()
              local arguments = { vim.api.nvim_buf_get_name(bufnr) }
              local title_str = export_type and ('Export ' .. cmd_display) or cmd_display
              local function handler(err, res)
                if err then
                  return vim.notify(err.code .. ': ' .. err.message, vim.log.levels.ERROR)
                end
                vim.notify(export_type and res or vim.inspect(res), vim.log.levels.INFO)
              end
              if vim.fn.has 'nvim-0.11' == 1 then
                return client:exec_cmd({
                  title = title_str,
                  command = command_name,
                  arguments = arguments,
                }, { bufnr = bufnr }, handler)
              else
                return vim.notify('Tinymist commands require Neovim 0.11+', vim.log.levels.WARN)
              end
            end
            local cmd_name = export_type and ('LspTinymistExport' .. cmd_display) or ('LspTinymist' .. cmd_display)
            local cmd_desc = export_type and ('Export to ' .. cmd_display) or ('Get ' .. cmd_display)
            return run_tinymist_command, cmd_name, cmd_desc
          end

          for _, command in ipairs {
            'tinymist.exportSvg',
            'tinymist.exportPng',
            'tinymist.exportPdf',
            'tinymist.exportMarkdown',
            'tinymist.exportText',
            'tinymist.exportQuery',
            'tinymist.exportAnsiHighlight',
            'tinymist.getServerInfo',
            'tinymist.getDocumentTrace',
            'tinymist.getWorkspaceLabels',
            'tinymist.getDocumentMetrics',
          } do
            local cmd_func, cmd_name, cmd_desc = create_tinymist_command(command, client, bufnr)
            vim.api.nvim_buf_create_user_command(bufnr, cmd_name, cmd_func, { nargs = 0, desc = cmd_desc })
          end
        end
      '';
    };
  };

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
      enable = mkEnableOption "Typst treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "typst";
    };

    lsp = {
      enable = mkEnableOption "Typst LSP support (typst-lsp)" // {default = config.vim.lsp.enable;};

      servers = mkOption {
        type = deprecatedSingleOrListOf "vim.language.typst.lsp.servers" (enum (attrNames servers));
        default = defaultServers;
        description = "Typst LSP server to use";
      };
    };

    format = {
      enable = mkEnableOption "Typst document formatting" // {default = config.vim.languages.enableFormat;};

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
      vim.lsp.servers =
        mapListToAttrs (n: {
          name = n;
          value = servers.${n};
        })
        cfg.lsp.servers;
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
