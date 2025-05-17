{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.utility.images.img-clip;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = [
        "img-clip"
      ];

      pluginRC.image-nvim = entryAnywhere ''
        require("img-clip").setup(${toLuaObject cfg.setupOpts})
      '';
    };
  };
}
