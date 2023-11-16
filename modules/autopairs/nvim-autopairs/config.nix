{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf nvim optionalString boolToString;

  cfg = config.vim.autopairs;
in {
  config =
    mkIf (cfg.enable)
    {
      vim.startPlugins = ["nvim-autopairs"];

      vim.luaConfigRC.autopairs = nvim.dag.entryAnywhere ''
        require("nvim-autopairs").setup{}
        ${optionalString (config.vim.autocomplete.type == "nvim-compe") ''
          require('nvim-autopairs.completion.compe').setup({
            map_cr = ${boolToString cfg.nvim-compe.map_cr},
            map_complete = ${boolToString cfg.nvim-compe.map_complete},
            auto_select = ${boolToString cfg.nvim-compe.auto_select},
          })
        ''}
      '';
    };
}
