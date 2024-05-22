{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.binds) mkBinding pushDownDefault;
  inherit (lib.nvim.dag) entryAnywhere;

  cfg = config.vim.tabline.cokeline;

  self = import ./cokeline.nix {inherit lib;};
  inherit (self.options.vim.tabline.cokeline) mappings;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = [
        (assert config.vim.visuals.nvimWebDevicons.enable; "nvim-cokeline")
        "bufdelete-nvim"
      ];

      maps.normal = mkMerge [
        (mkBinding cfg.mappings.cycleNext "<Plug>(cokeline-focus-next)" mappings.cycleNext.description)
        (mkBinding cfg.mappings.cyclePrevious "<Plug>(cokeline-focus-prev)" mappings.cyclePrevious.description)
        (mkBinding cfg.mappings.switchNext "<Plug>(cokeline-switch-next)" mappings.switchNext.description)
        (mkBinding cfg.mappings.switchPrevious "<Plug>(cokeline-switch-prev)" mappings.switchPrevious.description)
        # this does not work
        # (mkBinding cfg.mappings.pick "<Plug>(cokeline-pick-focus)" mappings.pick.description)
        # (mkLuaBinding cfg.mappings.pick "function() require('cokeline.mappings').pick(\"focus\") end" mappings.pick.description)
        # (mkBinding cfg.mappings.closeByLetter "<Plug>(cokeline-pick-close)" mappings.closeByLetter.description)
      ];

      binds.whichKey.register = pushDownDefault {
        "<leader>b" = "+Buffer";
        "<leader>bm" = "BufferLineMove";
      };

      luaConfigRC = {
        cokeline = entryAnywhere ''
          local get_hex = require('cokeline.hlgroups').get_hl_attr

          require('cokeline').setup({
            default_hl = {
              fg = function(buffer)
                return
                  buffer.is_focused
                  and get_hex('Normal', 'fg')
                   or get_hex('Comment', 'fg')
              end,
              bg = get_hex('ColorColumn', 'bg'),
            },

            components = {
              {
                text = ' ',
                bg = get_hex('Normal', 'bg'),
              },
              {
                text = '',
                fg = get_hex('ColorColumn', 'bg'),
                bg = get_hex('Normal', 'bg'),
              },
              {
                text = function(buffer)
                  return buffer.devicon.icon
                end,
                fg = function(buffer)
                  return buffer.devicon.color
                end,
              },
              {
                text = ' ',
              },
              {
                text = function(buffer) return buffer.filename .. '  ' end,
                style = function(buffer)
                  return buffer.is_focused and 'bold' or nil
                end,
              },
              {
                text = '',
                delete_buffer_on_left_click = true,
              },
              {
                text = '',
                fg = get_hex('ColorColumn', 'bg'),
                bg = get_hex('Normal', 'bg'),
              },
            },
          })
        '';
      };
    };
  };
}
