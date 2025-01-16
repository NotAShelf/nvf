{
  options,
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib) mkMerge;
  inherit (lib.modules) mkIf;
  inherit (lib.strings) concatStringsSep;
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.collections.mini-nvim;
in {
  config = mkIf cfg.enable {
    vim.lazy.plugins."mini-nvim" = {
      package = "mini-nvim";
      # package = pkgs.vimPlugins.mini-nvim;
      # package = pkgs.vimUtils.buildVimPlugin {
      #   name = "mini-nvim";
      #   src = inputs.plugin-mini-nvim;
      # };
      lazy = false;
      after = concatStringsSep "\n" (mapAttrsToList (name: value: ''
          require("mini.${name}").setup(${toLuaObject value.setupOpts})
        '')
        cfg.modules);
    };
  };
}
