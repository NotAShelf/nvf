{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.vim.utility.motion.precognition;
in {
  config =
    mkIf cfg.enable
    {
      vim = {
        startPlugins = ["precognition-nvim"];
        luaConfigRC.precognition = lib.nvim.dag.entryAnywhere ''
          require('precognition').setup(${lib.nvim.lua.toLuaObject cfg.setupOpts})
        '';
      };
    };
}
