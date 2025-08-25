{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.dag) entryAfter;

  cfg = config.vim.utility.qmk-nvim;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["qmk-nvim"];

      pluginRC.qmk-nvim = entryAfter ["nvim-notify"] ''
        require('qmk').setup(${toLuaObject cfg.setupOpts})
      '';
    };

    assertions = [
      {
        assertion = cfg.setupOpts.variant == "qmk" && cfg.setupOpts.comment_preview.position != "inside";
        message = "comment_preview.position can only be set to inside when using the qmk layoyt";
      }
      {
        assertion = cfg.setupOpts.name != null;
        message = "qmk-nvim requires 'vim.utility.qmk.setupOpts.name' to be set.";
      }
      {
        assertion = cfg.setupOpts.layout != null;
        message = "qmk-nvim requires 'vim.utility.qmk.setupOpts.layout' to be set.";
      }
    ];
  };
}
