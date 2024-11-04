{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (builtins) toString;

  cfg = config.vim.utility.motion.precognition;
in {
  config =
    mkIf cfg.enable
    {
      vim.startPlugins = [
        "precognition-nvim"
      ];

      vim.pluginRC.precognition-nvim = entryAnywhere ''
        require("precognition").setup({
             startVisible = ${toString cfg.startVisible},
             showBlankVirtLine = ${toString cfg.showBlankVirtLine},
             highlightColor = (${toLuaObject cfg.highlightColor}), --{ link = "Comment" },
             hints = (${toLuaObject cfg.hints}),
             gutterHints = (${toLuaObject cfg.gutterHints}),
             disabled_fts = (${toLuaObject cfg.disabled_fts}),
        });
      '';
    };
}
