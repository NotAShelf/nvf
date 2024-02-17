{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.strings) optionalString;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.autopairs;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = ["nvim-autopairs"];

    vim.luaConfigRC.autopairs = entryAnywhere ''
      require("nvim-autopairs").setup{}
      ${optionalString (config.vim.autocomplete.type == "nvim-compe") ''
        require('nvim-autopairs.completion.compe').setup(${toLuaObject cfg.setupOpts})
      ''}
    '';
  };
}
