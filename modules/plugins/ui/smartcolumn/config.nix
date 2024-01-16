{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf nvim concatStringsSep;

  cfg = config.vim.ui.smartcolumn;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = [
      "smartcolumn"
    ];

    vim.luaConfigRC.smartcolumn = nvim.dag.entryAnywhere ''
      require("smartcolumn").setup({
        colorcolumn = "${toString cfg.showColumnAt}",
        -- { "help", "text", "markdown", "NvimTree", "alpha"},
        disabled_filetypes = { ${concatStringsSep ", " (map (x: "\"" + x + "\"") cfg.disabledFiletypes)} },
        custom_colorcolumn = ${nvim.lua.attrsetToLuaTable cfg.columnAt.languages},
        scope = "file",
      })
    '';
  };
}
