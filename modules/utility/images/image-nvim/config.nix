{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) nvim mkIf attrValues;

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

      luaConfigRC.image-nvim = nvim.dag.entryAnywhere ''
        require("image").setup(
          ${nvim.lua.toLuaObject cfg.setupOpts}
        )
      '';
    };
  };
}
