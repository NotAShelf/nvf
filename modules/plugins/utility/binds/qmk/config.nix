{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.dag) entryAfter;

  cfg = config.vim.binds.qmk;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["qmk-nvim"];

      pluginRC.qmk-nvim = entryAfter ["nvim-notify"] ''
        require('qmk').setup(${toLuaObject cfg.setupOpts})
      '';
    };

    assertions = [{
      assertion = !(cfg.setupOpts.variant == "zmk") && !(cfg.setupOpts.comment_preview.position == "inside");
      message = "comment_preview.position can only be set to inside when using the qmk layoyt";
    }];
  };
}
