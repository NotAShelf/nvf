{
  lib,
  config,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.strings) optionalString;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.binds) addDescriptionsToMappings;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (builtins) attrNames;

  cfg = config.vim.autocomplete.nvim-cmp;
  vsnipEnable = config.vim.snippets.vsnip.enable;

  self = import ./nvim-cmp.nix {inherit lib config;};
  mappingDefinitions = self.options.vim.autocomplete.nvim-cmp.mappings;
  mappings = addDescriptionsToMappings cfg.mappings mappingDefinitions;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = [
        "nvim-cmp"
        "cmp-buffer"
        "cmp-path"
      ];

      autocomplete.nvim-cmp.sources = {
        nvim-cmp = null;
        buffer = "[Buffer]";
        path = "[Path]";
      };

      autopairs.nvim-autopairs.setupOpts.map_cr = false;

      autocomplete.nvim-cmp.setupOpts = {
        sources = map (s: {name = s;}) (attrNames cfg.sources);

        # TODO: try to get nvim-cmp to follow global border style
        window = mkIf config.vim.ui.borders.enable {
          completion = mkLuaInline "cmp.config.window.bordered()";
          documentation = mkLuaInline "cmp.config.window.bordered()";
        };

        formatting.format = cfg.format;
      };

      pluginRC.nvim-cmp = mkIf cfg.enable (entryAnywhere ''
        local cmp = require("cmp")
        cmp.setup(${toLuaObject cfg.setupOpts})

        ${
          optionalString config.vim.autopairs.nvim-autopairs.enable
          ''
            cmp.event:on('confirm_done', require("nvim-autopairs.completion.cmp").on_confirm_done({ map_char = { text = "" } }))
          ''
        }
      '');

      keymaps = [
        {
          mode = ["i" "c"];
          key = mappings.complete.value;
          lua = true;
          action = "require('cmp').complete";
          desc = mappings.complete.description;
        }

        {
          mode = "i";
          key = mappings.confirm.value;
          lua = true;
          action = let
            defaultKeys =
              if config.vim.autopairs.nvim-autopairs.enable
              then "require('nvim-autopairs').autopairs_cr()"
              else "vim.api.nvim_replace_termcodes(${toLuaObject mappings.confirm.value}, true, false, true)";
          in ''
            function()
              if not require('cmp').confirm({ select = true }) then
                vim.fn.feedkeys(${defaultKeys}, 'n')
              end
            end
          '';
          desc = mappings.confirm.description;
        }

        {
          mode = ["i" "s"];
          key = mappings.next.value;
          lua = true;
          action = ''
            function()
              local has_words_before = function()
                local line, col = unpack(vim.api.nvim_win_get_cursor(0))
                return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
              end

              local cmp = require('cmp')

              local feedkey = function(key, mode)
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
              end

              if cmp.visible() then
                cmp.select_next_item()
              ${
              optionalString vsnipEnable
              ''
                elseif vim.fn['vsnip#available'](1) == 1 then
                  feedkey("<Plug>(vsnip-expand-or-jump)", "")
              ''
            }
              elseif has_words_before() then
                cmp.complete()
              else
                vim.fn.feedkeys(vim.api.nvim_replace_termcodes(${toLuaObject mappings.next.value}, true, false, true), 'n')
              end
            end
          '';
          desc = mappings.next.description;
        }

        {
          mode = ["i" "s"];
          key = mappings.previous.value;
          lua = true;
          action = ''
            function()
              local cmp = require('cmp')

              local feedkey = function(key, mode)
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
              end

              if cmp.visible() then
                cmp.select_prev_item()
              ${
              optionalString vsnipEnable
              ''
                elseif vim.fn['vsnip#available'](-1) == 1 then
                  feedkeys("<Plug>(vsnip-jump-prev)", "")
              ''
            }
              end
            end
          '';
          desc = mappings.previous.description;
        }

        {
          mode = ["i" "c"];
          key = mappings.close.value;
          lua = true;
          action = "require('cmp').mapping.abort()";
          desc = mappings.close.description;
        }

        {
          mode = ["i" "c"];
          key = mappings.scrollDocsUp.value;
          lua = true;
          action = "require('cmp').mapping.scroll_docs(-4)";
          desc = mappings.scrollDocsUp.description;
        }

        {
          mode = ["i" "c"];
          key = mappings.scrollDocsDown.value;
          lua = true;
          action = "require('cmp').mapping.scroll_docs(4)";
          desc = mappings.scrollDocsDown.description;
        }
      ];
    };
  };
}
