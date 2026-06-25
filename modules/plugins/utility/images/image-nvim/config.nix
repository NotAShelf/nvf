{
  config,
  lib,
  pkgs,
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

      luaPackages = mkIf (cfg.setupOpts.processor == "magick_rock") [
        "magick"
      ];

      extraPackages = mkIf (cfg.setupOpts.processor == "magick_cli") [
        pkgs.imagemagick
      ];

      pluginRC.image-nvim = entryAnywhere ''
        require("image").setup(
          ${toLuaObject cfg.setupOpts}
        )
      '';
    };
  };
}
