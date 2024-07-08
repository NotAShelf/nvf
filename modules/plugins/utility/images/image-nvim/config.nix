{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.utility.images.image-nvim;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = [
        "image-nvim"
      ];

      luaPackages = [
        "magick"
      ];

      luaConfigRC.image-nvim = entryAnywhere ''
        require("image").setup(
          ${toLuaObject cfg.setupOpts}
        )
      '';
    };
  };
}
