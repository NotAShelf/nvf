{
  config,
  lib,
  ...
}: let
  inherit (lib) addDescriptionsToMappings mkIf mkMerge mkSetLuaBinding nvim;

  cfg = config.vim.gestures.gesture-nvim;

  self = import ./gesture-nvim.nix {inherit lib;};

  mappingDefinitions = self.options.vim.gestures.gesture-nvim.mappings;
  mappings = addDescriptionsToMappings cfg.mappings mappingDefinitions;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = ["gesture-nvim"];

    vim.maps.normal = mkMerge [
      (mkSetLuaBinding mappings.draw "require('gesture').draw")
      (mkSetLuaBinding mappings.finish "require('gesture').finish")
      (mkIf (mappings.draw.value == "<RightDrag>") {
        "<RightMouse>" = {action = "<Nop>";};
      })
    ];

    vim.luaConfigRC.gesture-nvim = nvim.dag.entryAnywhere ''
      vim.opt.mouse = "a"

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
}
