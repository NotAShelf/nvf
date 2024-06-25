{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.autopairs;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = ["nvim-autopairs"];

    vim.luaConfigRC.autopairs = entryAnywhere ''
      require("nvim-autopairs").setup({ map_cr = ${toLuaObject (!config.vim.autocomplete.enable)} })
    '';
  };
}
