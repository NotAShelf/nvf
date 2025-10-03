{
  config,
  lib,
  options,
  ...
}: let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.binds) addDescriptionsToMappings mkSetLuaBinding;
  inherit (lib.nvim.dag) entryAnywhere;

  cfg = config.vim.gestures.gesture-nvim;

  mappingDefinitions = options.vim.gestures.gesture-nvim.mappings;
  mappings = addDescriptionsToMappings cfg.mappings mappingDefinitions;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["gesture-nvim"];

      maps.normal = mkMerge [
        (mkSetLuaBinding mappings.draw "require('gesture').draw")
        (mkSetLuaBinding mappings.finish "require('gesture').finish")
        (mkIf (mappings.draw.value == "<RightDrag>") {
          "<RightMouse>" = {action = "<Nop>";};
        })
      ];

      options.mouse = "a";
      pluginRC.gesture-nvim = entryAnywhere ''
        local gesture = require("gesture")
        gesture.register({
          name = "scroll to bottom",
          inputs = { gesture.up(), gesture.down() },
          action = "normal! G",
        })

        gesture.register({
          name = "next tab",
          inputs = { gesture.right() },
          action = "tabnext",
        })

        gesture.register({
          name = "previous tab",
          inputs = { gesture.left() },
          action = function(ctx) -- also can use callable
            vim.cmd.tabprevious()
          end,
        })

        gesture.register({
          name = "go back",
          inputs = { gesture.right(), gesture.left() },
          -- map to `<C-o>` keycode
          action = [[lua vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-o>", true, false, true), "n", true)]],
        })
      '';
    };
  };
}
