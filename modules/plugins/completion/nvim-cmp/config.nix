{
  lib,
  config,
  ...
}: let
  inherit (lib.modules) mkIf mkMerge mkDefault;
  inherit (lib.strings) optionalString;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.attrsets) mapListToAttrs;
  inherit (builtins) attrNames typeOf tryEval concatStringsSep;

  borders = config.vim.ui.borders.plugins.nvim-cmp;
  # From https://github.com/hrsh7th/nvim-cmp/blob/main/lua/cmp/config/window.lua
  # This way users can still override the options
  windowOpts = {
    border = borders.style;
    winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None";
    zindex = 1001;
    scrolloff = 0;
    col_offset = 0;
    side_padding = 1;
    scrollbar = true;
  };

  cfg = config.vim.autocomplete.nvim-cmp;
  luasnipEnable = config.vim.snippets.luasnip.enable;
  getPluginName = plugin:
    if typeOf plugin == "string"
    then plugin
    else if (plugin ? pname && (tryEval plugin.pname).success)
    then plugin.pname
    else plugin.name;
  inherit (cfg) mappings;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["rtp-nvim"];
      lazy.plugins = mkMerge [
        (mapListToAttrs (package: {
            name = getPluginName package;
            value = {
              inherit package;
              lazy = true;
              after = ''
                local path = vim.fn.globpath(vim.o.packpath, 'pack/*/opt/${getPluginName package}')
                require("rtp_nvim").source_after_plugin_dir(path)
              '';
            };
          })
          cfg.sourcePlugins)
        {
          nvim-cmp = {
            package = "nvim-cmp";
            after = ''
              ${optionalString luasnipEnable "local luasnip = require('luasnip')"}
              local cmp = require("cmp")

              local kinds = require("cmp.types").lsp.CompletionItemKind
              local deprio = function(kind)
                return function(e1, e2)
                  if e1:get_kind() == kind then
                    return false
                  end
                  if e2:get_kind() == kind then
                    return true
                  end
                  return nil
                end
              end

              cmp.setup(${toLuaObject cfg.setupOpts})

              ${optionalString config.vim.lazy.enable
                (concatStringsSep "\n" (map
                  (package: "require('lz.n').trigger_load(${toLuaObject (getPluginName package)})")
                  cfg.sourcePlugins))}
            '';

            event = ["InsertEnter" "CmdlineEnter"];
          };
        }
      ];

      autocomplete.nvim-cmp = {
        sources = {
          nvim-cmp = null;
          buffer = "[Buffer]";
          path = "[Path]";
        };

        sourcePlugins = ["cmp-buffer" "cmp-path"];

        setupOpts = {
          sources = map (s: {name = s;}) (attrNames cfg.sources);

          window = mkIf borders.enable {
            completion = mkDefault windowOpts;
            documentation = mkDefault windowOpts;
          };

          formatting.format = cfg.format;

          # `cmp` and `luasnip` are defined above, in the `nvim-cmp` section
          mapping = {
            ${mappings.complete} = mkLuaInline "cmp.mapping.complete()";
            ${mappings.close} = mkLuaInline "cmp.mapping.abort()";
            ${mappings.scrollDocsUp} = mkLuaInline "cmp.mapping.scroll_docs(-4)";
            ${mappings.scrollDocsDown} = mkLuaInline "cmp.mapping.scroll_docs(4)";
            ${mappings.confirm} = mkLuaInline "cmp.mapping.confirm({ select = true })";

            ${mappings.next} = mkLuaInline ''
              cmp.mapping(function(fallback)
                local has_words_before = function()
                  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
                  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
                end

                if cmp.visible() then
                  cmp.select_next_item()
                  ${optionalString luasnipEnable ''
                elseif luasnip.locally_jumpable(1) then
                  luasnip.jump(1)
              ''}
                elseif has_words_before() then
                  cmp.complete()
                else
                  fallback()
                end
              end)
            '';

            ${mappings.previous} = mkLuaInline ''
              cmp.mapping(function(fallback)
                if cmp.visible() then
                  cmp.select_prev_item()
                  ${optionalString luasnipEnable ''
                elseif luasnip.locally_jumpable(-1) then
                  luasnip.jump(-1)
              ''}
                else
                  fallback()
                end
              end)
            '';
          };
        };
      };
    };
  };
}
