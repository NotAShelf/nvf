{
  config,
  lib,
  ...
}: let
  inherit (lib.attrsets) filterAttrs mapAttrs';
  inherit (lib.lists) map count;
  inherit (lib.modules) mkIf mkMerge mkDefault;
  inherit (lib.trivial) boolToString;
  inherit (lib.nvim.dag) entryAnywhere entryAfter;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.statusline.lualine;

  cfgIntBreadcrumbs = cfg.integrations.breadcrumbs;
in {
  config = mkMerge [
    {
      vim.statusline.lualine.setupOpts.extensions =
        (lib.optionals config.vim.filetree.nvimTree.enable ["nvim-tree"])
        ++ (lib.optionals config.vim.filetree.neo-tree.enable ["neo-tree"])
        ++ (lib.optionals config.vim.utility.snacks-nvim.enable [
          {
            # same extensions as nerdtree / neo-tree
            # https://github.com/nvim-lualine/lualine.nvim/blob/master/lua/lualine/extensions/nerdtree.lua
            # https://github.com/nvim-lualine/lualine.nvim/blob/master/lua/lualine/extensions/neo-tree.lua
            sections = {
              lualine_a = mkLuaInline ''
                {
                  function()
                    return vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
                  end,
                }
              '';
            };
            filetypes = ["snacks_picker_list" "snacks_picker_input"];
          }
        ]);
    }

    {
      assertions = [
        {
          assertion =
            count (x: x) (with cfgIntBreadcrumbs; [
              vanilla.enable
              nvim-navic.enable
              lspsaga.enable
            ])
            <= 1;

          message = ''
            Only one lualine breadcrumb integration can be enabled at once.
          '';
        }
      ];
    }

    (mkIf cfgIntBreadcrumbs.vanilla.enable {
      vim.statusline.lualine.setupOpts."${cfgIntBreadcrumbs.location}"."lualine_${cfgIntBreadcrumbs.section}" = [
        (
          mkLuaInline ''
            function()
              local buffer = vim.api.nvim_get_current_buf()

              local supported = false
              for _, client in pairs(vim.lsp.get_clients({ bufnr = buffer })) do
                if client.server_capabilities.documentSymbolProvider then
                  supported = true
                  break
                end
              end

              if not supported then
                return ""
              end

              local responses = vim.lsp.buf_request_sync(
                buffer,
                "textDocument/documentSymbol",
                { textDocument = { uri = vim.uri_from_bufnr(buffer) } },
                100
              )

              local symbols
              for _, response in pairs(responses or {}) do
                if response.result then
                  symbols = response.result
                  break
                end
              end

              if not symbols then
                return ""
              end

              local cursor_line, cursor_column = unpack(vim.api.nvim_win_get_cursor(0))
              cursor_line = cursor_line - 1
              local names = {}

              local function find_symbols(symbols)
                for _, symbol in ipairs(symbols or {}) do
                  local range = symbol.range

                  if
                    range
                    and (cursor_line > range.start.line or cursor_line == range.start.line and cursor_column >= range.start.character)
                    and (
                      cursor_line < range["end"].line
                      or cursor_line == range["end"].line and cursor_column <= range["end"].character
                    )
                  then
                    names[#names + 1] = symbol.name
                    find_symbols(symbol.children)
                    return
                  end
                end
              end

              find_symbols(symbols)
              return table.concat(names, "%#${cfgIntBreadcrumbs.vanilla.separator.color}#${cfgIntBreadcrumbs.vanilla.separator.symbol}%*")
            end
          ''
        )
      ];
    })

    (mkIf cfgIntBreadcrumbs.nvim-navic.enable {
      vim = {
        startPlugins = [
          "nvim-lspconfig"
          "nvim-navic"
        ];
        statusline.lualine.setupOpts."${cfgIntBreadcrumbs.location}"."lualine_${cfgIntBreadcrumbs.section}" = [
          [
            "navic"
            (mkLuaInline "draw_empty = ${boolToString cfgIntBreadcrumbs.nvim-navic.alwaysRender}")
          ]
        ];

        pluginRC.breadcrumbs-navic = entryAfter ["lspconfig"] ''
          local navic = require("nvim-navic")
          require("nvim-navic").setup({
            highlight = true,
          })
        '';

        autocmds = [
          {
            event = ["LspAttach"];
            callback = mkLuaInline ''
              function(event)
                local bufnr = event.buf
                local client = vim.lsp.get_client_by_id(event.data.client_id)
                if client.server_capabilities.documentSymbolProvider then
                  require("nvim-navic").attach(client, bufnr)
                end
              end
            '';
          }
        ];
      };
    })

    (mkIf cfgIntBreadcrumbs.navbuddy.enable {
      vim = {
        statusline.lualine.integrations.breadcrumbs.nvim-navic.enable = true;

        startPlugins = [
          "nvim-navbuddy"
          "nui-nvim"
        ];

        pluginRC.breadcrumbs-navbuddy = entryAfter ["lspconfig" "breadcrumbs-navic"] ''
          local navbuddy = require("nvim-navbuddy")
          local actions = require("nvim-navbuddy.actions")
          navbuddy.setup ${toLuaObject (
            cfgIntBreadcrumbs.navbuddy.setupOpts
            // {
              mappings =
                mapAttrs'
                (name: key: {
                  inherit name;
                  value =
                    {
                      close = mkLuaInline "actions.close()";
                      nextSibling = mkLuaInline "actions.next_sibling()";
                      previousSibling = mkLuaInline "actions.previous_sibling()";
                      parent = mkLuaInline "actions.parent()";
                      children = mkLuaInline "actions.children()";
                      root = mkLuaInline "actions.root()";

                      visualName = mkLuaInline "actions.visual_name()";
                      visualScope = mkLuaInline "actions.visual_scope()";

                      yankName = mkLuaInline "actions.yank_name()";
                      yankScope = mkLuaInline "actions.yank_scope()";

                      insertName = mkLuaInline "actions.insert_name()";
                      insertScope = mkLuaInline "actions.insert_scope()";

                      appendName = mkLuaInline "actions.append_name()";
                      appendScope = mkLuaInline "actions.append_scope()";

                      rename = mkLuaInline "actions.rename()";
                      delete = mkLuaInline "actions.delete()";

                      foldCreate = mkLuaInline "actions.fold_create()";
                      foldDelete = mkLuaInline "actions.fold_delete()";

                      comment = mkLuaInline "actions.comment()";
                      select = mkLuaInline "actions.select()";

                      moveDown = mkLuaInline "actions.move_down()";
                      moveUp = mkLuaInline "actions.move_up()";

                      togglePreview = mkLuaInline "actions.toggle_preview()";

                      vsplit = mkLuaInline "actions.vsplit()";
                      hsplit = mkLuaInline "actions.hsplit()";

                      telescope = mkLuaInline ''
                        actions.telescope({
                          layout_strategy = "horizontal",
                          layout_config = {
                            height = 0.60,
                            width = 0.75,
                            prompt_position = "top",
                            preview_width = 0.50,
                          },
                        })
                      '';

                      help = mkLuaInline "actions.help()";
                    }.${
                      name
                    };
                })
                (filterAttrs (_: key: key != null) cfgIntBreadcrumbs.navbuddy.mappings);
            }
          )}

        '';
      };
    })

    (mkIf cfgIntBreadcrumbs.lspsaga.enable {
      vim = {
        lsp.lspsaga = {
          enable = true;
          setupOpts.symbol_in_winbar.enable = true;
        };
        statusline.lualine.setupOpts."${cfgIntBreadcrumbs.location}"."lualine_${cfgIntBreadcrumbs.section}" = [
          (
            mkLuaInline ''
              function()
                return require("lspsaga.symbol.winbar").get_bar()
              end
            ''
          )
        ];
      };
    })

    (mkIf cfg.enable {
      vim = {
        startPlugins = ["lualine-nvim"];
        pluginRC.lualine = entryAnywhere ''
          local lualine = require('lualine')
          lualine.setup ${toLuaObject cfg.setupOpts}
        '';
      };
    })
  ];
}
