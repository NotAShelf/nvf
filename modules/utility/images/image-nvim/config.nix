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
      startPlugins =
        [
          "image-nvim"
          # TODO: needs luarockss here somehow
        ]
        ++ (attrValues {inherit (pkgs) luarocks imagemagick;});

      luaConfigRC.image-nvim = nvim.dag.entryAnywhere ''
        require("image").setup(
          ${nvim.lua.toLuaObject cfg.setupOpts}
        )
      '';
    };
  };
}
