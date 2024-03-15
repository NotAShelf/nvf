{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.strings) concatStringsSep;
  inherit (lib.nvim.lua) attrsetToLuaTable;
  inherit (lib.nvim.dag) entryAnywhere;

  cfg = config.vim.ui.smartcolumn;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["smartcolumn"];

    vim.luaConfigRC.smartcolumn = entryAnywhere ''
      require("smartcolumn").setup({
        colorcolumn = "${toString cfg.showColumnAt}",
        -- { "help", "text", "markdown", "NvimTree", "alpha"},
        disabled_filetypes = { ${concatStringsSep ", " (map (x: "\"" + x + "\"") cfg.disabledFiletypes)} },
        custom_colorcolumn = ${attrsetToLuaTable cfg.columnAt.languages},
        scope = "file",
      })
    '';
  };
}
