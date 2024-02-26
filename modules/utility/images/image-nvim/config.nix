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
    assertions = [
      {
        assertion = pkgs.stdenv.isDarwin && cfg.setupOpts.backend != "ueberzug";
        message = "image-nvim: ueberzug backend is broken on ${pkgs.stdenv.hostPlatform.system}. if you are using kitty, please set `vim.utility.images.image-nvim.setupOpts.backend` option to `kitty` in your configuration, otherwise disable this module.";
      }
    ];

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
