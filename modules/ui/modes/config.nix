{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf nvim boolToString;

  cfg = config.vim.ui.modes-nvim;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = [
      "modes-nvim"
    ];

    vim.luaConfigRC.modes-nvim = nvim.dag.entryAnywhere ''
      require('modes').setup({
        set_cursorline = ${boolToString cfg.setCursorline},
        line_opacity = {
          visual = 0,
        },
        colors = {
          copy = "${toString cfg.colors.copy}",
          delete = "${toString cfg.colors.delete}",
          insert = "${toString cfg.colors.insert}",
          visual = "${toString cfg.colors.visual}",
        },
      })
    '';
  };
}
