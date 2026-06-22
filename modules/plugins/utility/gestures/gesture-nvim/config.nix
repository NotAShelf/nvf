{
  config,
  lib,
  options,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.lists) optional;
  inherit (lib.nvim.binds) mkKeymap;
  inherit (lib.nvim.dag) entryAnywhere;

  cfg = config.vim.gestures.gesture-nvim;

  inherit (options.vim.gestures.gesture-nvim) mappings;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["gesture-nvim"];

      keymaps =
        [
          (mkKeymap "n" cfg.mappings.draw "require('gesture').draw" {
            desc = mappings.draw.description;
            lua = true;
          })
          (mkKeymap "n" cfg.mappings.finish "require('gesture').finish" {
            desc = mappings.finish.description;
            lua = true;
          })
        ]
        ++ optional
        (cfg.mappings.draw == "<RightDrag>")
        (mkKeymap "n" "<RightMouse>" "<Nop>" {desc = "Disable right mouse";});

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
