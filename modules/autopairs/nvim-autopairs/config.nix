{
  config,
  lib,
  ...
}: let
  inherit (lib) nvim;
  inherit (lib.modules) mkIf;
  inherit (lib.strings) optionalString;

  cfg = config.vim.autopairs;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = ["nvim-autopairs"];

    vim.luaConfigRC.autopairs = nvim.dag.entryAnywhere ''
      require("nvim-autopairs").setup{}
      ${optionalString (config.vim.autocomplete.type == "nvim-compe") ''
        require('nvim-autopairs.completion.compe').setup(${nvim.lua.expToLua cfg.setupOpts})
      ''}
    '';
  };
}
