{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
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
         custom_colorcolumn = {
           -- TODO: use cfg.languages.<language>.columnAt when it's fixed to dynamically define per-language length
           ruby = "120",
           java = "120",
           nix = "120",
           markdown = "80",
         },
         scope = "file",
      })
    '';
  };
}
